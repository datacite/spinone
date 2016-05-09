module Trackable
  extend ActiveSupport::Concern

  require "redis"

  included do
    def count_key
      if Rails.env.test?
        "#{name}_test:count"
      else
        "#{name}:count"
      end
    end

    def count
      (redis.get count_key).to_i
    end

    def count=(number)
      redis.set count_key, number.to_s
    end

    def update_count(message_size)
      self.count += message_size.to_i
    end
  end
end
