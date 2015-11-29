require 'redis'

module Sinatra
  module RedisClient
    def redis
      @redis ||= Redis.new
    end
  end
end
