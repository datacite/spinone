require 'sinatra/base'
require 'sidekiq'

module Sinatra
  module Heartbeat
    def services_up?
      [redis_up?, sidekiq_up?].all?
    end

    def redis_up?
      redis_client = Redis.new
      redis_client.ping == "PONG"
    rescue
      false
    end

    def sidekiq_up?
      sidekiq_client = Sidekiq::ProcessSet.new
      sidekiq_client.size > 0
    rescue
      false
    end
  end

  helpers Heartbeat
end
