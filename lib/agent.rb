require 'sinatra/base'
require 'json'
require 'maremma'
require 'parse-cron'
require_relative 'formatting'
require_relative 'redis_client'

class Agent
  include Sinatra::Formatting
  include Sinatra::RedisClient

  def self.all
    Agent.descendants.map { |a| a.new }.sort_by { |agent| agent.name }
  end

  def self.find_by_uuid(param)
    all.find { |agent| agent.uuid == param }
  end

  def source_id
    'datacite_' + name
  end

  def process_data(options)
    result = get_data(options)
    result = parse_data(result)
    push_data(result)
  end

  def get_data(options={})
    query_url = get_query_url(options)
    Maremma.get(query_url, options)
  end

  def get_total(options={})
    query_url = get_query_url(options.merge(rows: 0))
    result = Maremma.get(query_url, options)
    result.fetch("response", {}).fetch("numFound", 0)
  end

  def queue_jobs(options={})
    total = get_total(options)

    if total > 0
      # walk through paginated results
      total_pages = (total.to_f / job_batch_size).ceil

      (0...total_pages).each do |page|
        options[:offset] = page * job_batch_size
        AgentJob.perform_async(name, options)
      end
    end

    # return number of works queued
    total
  end

  def parse_data(result)
    result = { error: "No hash returned." } unless result.is_a?(Hash)
    return result if result[:error]

    items = result.fetch('response', {}).fetch('docs', nil)

    { works: get_works(items),
      events: get_events(items) }
  end

  def get_works(items)
    []
  end

  def get_events(items)
    []
  end

  # push to deposit API if no error and we have collected works and/or events
  def push_data(result)
    return {} unless result.fetch(:works, []).present? ||
                     result.fetch(:events, []).present? ||
                     result.fetch(:contributors, []).present? ||
                     result.fetch(:publishers, []).present?

    callback = "#{ENV['SERVER_URL']}/api/agents"
    deposit = { deposit: { source_token: uuid,
                           message: result,
                           message_type: source_id,
                           callback: callback }}

    Maremma.post push_url, data: deposit, token: access_token
  end

  def url
    "http://search.datacite.org/api?"
  end

  def update_status(message_size)
    self.scheduled_at = Time.now.iso8601
    self.count += message_size.to_i
  end

  def timestamp_key
    "#{name}:timestamp"
  end

  def count_key
    "#{name}:count"
  end

  def scheduled_at
    redis.get timestamp_key || Time.now.iso8601
  end

  def scheduled_at=(timestamp)
    cron_parser = CronParser.new(cron_line)
    time = cron_parser.next(Time.iso8601(timestamp))
    redis.set timestamp_key, time.iso8601
  end

  def count
    (redis.get count_key).to_i
  end

  def count=(number)
    redis.set count_key, number.to_s
  end

  def stale?
    scheduled_at.to_s <= Time.now.iso8601
  end
end
