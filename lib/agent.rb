require 'sinatra/base'
require 'json'
require_relative 'network'
require_relative 'helpers'

class Agent
  include Sinatra::Network
  include Sinatra::Helpers

  def process_data(options)
    result = get_data(options)
    result = parse_data(result)
    result.length
  end

  def get_data(options={})
    query_url = get_query_url(options)
    get_result(query_url, options)
  end

  def get_total(options={})
    query_url = get_query_url(options.merge(rows: 0))
    result = get_result(query_url, options)
    result.fetch("response", {}).fetch("numFound", 0)
  end

  def queue_jobs(options={})
    total = get_total(options)

    if total > 0
      # walk through paginated results
      total_pages = (total.to_f / job_batch_size).ceil

      (0...total_pages).each do |page|
        options[:offset] = page * job_batch_size
        AgentJob.perform_async(self, options)
      end
    end

    # return number of works queued
    total
  end

  def parse_data(result, options={})
    result = { error: "No hash returned." } unless result.is_a?(Hash)
    return result if result[:error]

    items = result.fetch('response', {}).fetch('docs', nil)
    get_works(items).flatten
  end

  def url
    "http://search.datacite.org/api?"
  end
end
