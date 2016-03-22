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
    result.fetch("data", {}).fetch("response", {}).fetch("numFound", 0)
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

    # return number of works or contributors queued
    total
  end

  def parse_data(result)
    return result if result["errors"]

    items = result.fetch("data", {}).fetch('response', {}).fetch('docs', nil)
    get_relations_with_related_works(items)
  end

  # push to deposit API if no error and we have collected works
  def push_data(items)
    return [] if items.empty?

    callback = "#{ENV['SERVER_URL']}/api/agents"

    Array(items).map do |item|
      relation = item.fetch(:relation, {})
      deposit = { "deposit" => { "subj_id" => relation.fetch("subj_id", nil),
                                 "obj_id" => relation.fetch("obj_id", nil),
                                 "relation_type_id" => relation.fetch("relation_type_id", nil),
                                 "source_id" => relation.fetch("source_id", nil),
                                 "publisher_id" => relation.fetch("publisher_id", nil),
                                 "subj" => item.fetch(:subj, {}),
                                 "obj" => item.fetch(:obj, {}),
                                 "message_type" => item.fetch(:message_type, nil),
                                 "prefix" => item.fetch(:prefix, nil),
                                 "source_token" => uuid,
                                 "callback" => callback } }

      Maremma.post push_url, data: deposit, token: access_token
    end
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
