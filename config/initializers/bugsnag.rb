Bugsnag.configure do |config|
  config.api_key = ENV['BUGSNAG_API_KEY']
  config.notify_release_stages = %w(stage production)
  config.app_version = Spinone::Application::VERSION
  config.auto_capture_sessions = true
end
