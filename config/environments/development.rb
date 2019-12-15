Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # config.action_controller.perform_caching = true
  config.action_controller.perform_caching = true
  config.cache_store = :dalli_store

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false
  #
  # config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end

BetterErrors::Middleware.allow_ip! ENV['TRUSTED_IP']

# HttpLog.configure do |config|
#   config.logger = ActiveSupport::Logger.new(STDOUT)
#   config.severity = Logger::Severity::DEBUG
# end
