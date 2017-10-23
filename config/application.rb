require File.expand_path('../boot', __FILE__)

require "active_model/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

require 'syslog/logger'
require 'securerandom'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# load ENV variables from .env file if it exists
env_file = File.expand_path("../../.env", __FILE__)
if File.exist?(env_file)
  require 'dotenv'
  Dotenv.load! env_file
end

# load ENV variables from container environment if json file exists
# see https://github.com/phusion/baseimage-docker#envvar_dumps
env_json_file = "/etc/container_environment.json"
if File.exist?(env_json_file)
  env_vars = JSON.parse(File.read(env_json_file))
  env_vars.each { |k, v| ENV[k] = v }
end

# default values for some ENV variables
ENV['APPLICATION'] ||= "spinone"
ENV['HOSTNAME'] ||= "api.local"
ENV['MEMCACHE_SERVERS'] ||= "localhost:11211"
ENV['SITE_TITLE'] ||= "DataCite API"
ENV['LOG_LEVEL'] ||= "info"
ENV['BRACCO_URL'] ||= "https://doi.datacite.org"
ENV['LUPO_URL'] ||= "https://api.datacite.org"
ENV['CDN_URL'] ||= "https://assets.datacite.org"
ENV['GITHUB_URL'] ||= "https://github.com/datacite/spinone"
ENV['TRUSTED_IP'] ||= "127.0.0.0/8"

module Spinone
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir["#{config.root}/app/models/**/**", "#{config.root}/app/controllers/**/"]

    # add assets installed via bower
    config.assets.paths << "#{Rails.root}/vendor/bower_components"

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Prepend all log lines with the following tags.
    # config.log_tags = [ :subdomain, :uuid ]

    # configure logging
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
    config.lograge.enabled = true
    config.log_level = ENV['LOG_LEVEL'].to_sym

    # Use memcached as cache store
    config.cache_store = :dalli_store, nil, { :namespace => ENV['APPLICATION'], :compress => true }

    # compress responses with deflate or gzip
    config.middleware.use Rack::Deflater

    # Configure the default encoding used in templates for Ruby.
    config.encoding = "utf-8"

    # secret_key_base is not used by Rails API, as there are no sessions
    config.secret_key_base = 'blipblapblup'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :authentication_token, :jwt]

    # Skip validation of locale
    I18n.enforce_available_locales = false

    # Disable IP spoofing check
    config.action_dispatch.ip_spoofing_check = false

    # compress responses with deflate or gzip
    config.middleware.use Rack::Deflater

    # set Active Job queueing backend
    # config.active_job.queue_adapter = :sidekiq

    # Minimum Sass number precision required by bootstrap-sass
    #::Sass::Script::Value::Number.precision = [8, ::Sass::Script::Value::Number.precision].max

    # parameter keys that are not explicitly permitted will raise error
    config.action_controller.action_on_unpermitted_parameters = :raise
  end
end
