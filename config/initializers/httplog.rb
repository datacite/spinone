HttpLog.configure do |config|
  config.logger = Rails.logger
  config.log_headers = (ENV['LOG_LEVEL'] == "debug")
end
