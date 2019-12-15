require_relative 'boot'

require "rails"
require "active_model/railtie"
require "action_controller/railtie"
require "rails/test_unit/railtie"

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
ENV['MEMCACHE_SERVERS'] ||= "memcached:11211"
ENV['SITE_TITLE'] ||= "DataCite REST API"
ENV['LOG_LEVEL'] ||= "info"
ENV['BRACCO_URL'] ||= "https://doi.test.datacite.org"
ENV['API_URL'] ||= "https://api.test.datacite.org"
ENV['SOLR_URL'] ||= "https://solr.test.datacite.org/api"
ENV['LAGOTTO_URL'] ||= "https://eventdata.test.datacite.org/api"
ENV['VOLPINO_URL'] ||= "https://profiles.test.datacite.org/api"
ENV['BLOG_URL'] ||= "https://blog.test.datacite.org"
ENV['SCHEMA_URL'] ||= "https://schema.test.datacite.org"
ENV['GITHUB_URL'] ||= "https://github.com/datacite/spinone"
ENV['GITHUB_ISSUES_REPO_URL'] ||= "https://github.com/datacite/datacite"
ENV['GITHUB_MILESTONES_URL'] ||= "https://api.github.com/repos/datacite/datacite"
ENV['TRUSTED_IP'] ||= "127.0.0.0/8"

module Spinone
  class Application < Rails::Application
    config.api_only = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir["#{config.root}/app/models/**/**", "#{config.root}/app/controllers/**/"]

    # include graphql
    config.paths.add Rails.root.join('app', 'graphql', 'types').to_s, eager_load: true
    config.paths.add Rails.root.join('app', 'graphql', 'mutations').to_s, eager_load: true
    
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.fallbacks = true

    # Prepend all log lines with the following tags.
    # config.log_tags = [ :subdomain, :uuid ]

    # serve assets via web server
    config.public_file_server.enabled = false

    # configure caching
    config.cache_store = :dalli_store, nil, { :namespace => ENV['APPLICATION'] }

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

    # parameter keys that are not explicitly permitted will raise error
    config.action_controller.action_on_unpermitted_parameters = :raise
  end
end
