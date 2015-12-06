require 'redis'

module Sinatra
  module RedisClient
    def redis
      @redis ||= Redis.new(url: ENV['REDIS_URL'])
    end
  end
end
