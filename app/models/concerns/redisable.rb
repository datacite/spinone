module Redisable
  extend ActiveSupport::Concern

  require "redis"

  included do
    def redis
      @redis ||= Redis.new(url: ENV['REDIS_URL'])
    end
  end
end
