require 'net/smtp'
require 'timeout'

class Heartbeat < Sinatra::Base
  get '' do
    content_type :json

    { services: services,
      status: human_status(services_up?) }.to_json
  end

  def services
    { redis: human_status(redis_up?),
      sidekiq: human_status(sidekiq_up?),
      web: human_status(web_up?) }
  end

  def human_status(service)
    service ? "OK" : "failed"
  end

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

  def web_up?
    web_client = Faraday.new(url: "http://#{ENV['HOSTNAME']}")
    response = web_client.get '/'
    response.status == 200
  rescue
    false
  end
end
