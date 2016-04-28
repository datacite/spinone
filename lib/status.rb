require 'json'
require_relative 'redis_client'

class Status
  include Sinatra::RedisClient

  def status_key
    "status"
  end

  def write
    counts = { 'id' => SecureRandom.uuid,
               'version' => App::VERSION,
               'timestamp' => Time.now.iso8601 }
    Agent.descendants.map do |a|
      agent = a.new
      counts[agent.name] = agent.count
    end
    redis.lpush status_key, counts.to_json
  end

  def read
    string = redis.lrange(status_key, 0, 1000)
    string.map { |status| JSON.parse(status) }
  end

  def reset
    redis.del status_key
  end

  def counts
    read.map do |s|
      { 'id' => s['id'],
        'type' => 'status',
        'attributes' => {
          'github' => s['github'].to_i,
          'orcid' => s['orcid'].to_i,
          'orcid_update' => s['orcid_update'].to_i,
          'related_identifier' => s['related_identifier'].to_i,
          'version' => s['version'],
          'timestamp' => s['timestamp']
        }
      }
    end
  end
end
