begin
  # requires dotenv plugin/gem
  require 'dotenv'

  # make sure DOTENV is set, defaults to "default"
  ENV['DOTENV'] ||= 'default'

  # load ENV variables from file specified by DOTENV
  # use .env with DOTENV=default
  filename = ENV['DOTENV'] == 'default' ? '.env' : ".env.#{ENV['DOTENV']}"
  Dotenv.load! File.expand_path("../#{filename}", __FILE__)
rescue Errno::ENOENT
  $stderr.puts "Please create #{filename} file, or use DOTENV=example for example configuration"
  exit
end

# Check for required ENV variables, can be set in .env file
# ENV_VARS is hash of required ENV variables
env_vars = %w(HOSTNAME SERVERS SITENAME)
env_vars.each { |env| fail ArgumentError,  "ENV[#{env}] is not set" unless ENV[env] }
ENV_VARS = Hash[env_vars.map { |env| [env, ENV[env]] }]

# Constants
DEFAULT_TIMEOUT = 60

require 'sinatra'
require 'sinatra/json'
require 'sinatra/config_file'
require 'active_support/all'
require 'haml'
require 'will_paginate'
require 'will_paginate-bootstrap'
require 'cgi'
require 'faraday'
require 'faraday_middleware'
require 'faraday/encoding'
require 'gabba'
require 'rack-flash'
require 'omniauth/jwt'
require 'sidekiq'
require 'sidekiq/api'
require 'open-uri'
require 'uri'

NETWORKABLE_EXCEPTIONS = [Faraday::ClientError,
                          Faraday::TimeoutError,
                          Faraday::SSLError,
                          Faraday::ConnectionFailed,
                          URI::InvalidURIError,
                          Encoding::UndefinedConversionError,
                          ArgumentError,
                          NoMethodError,
                          TypeError]

Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |f| require f }

config_file "config/settings.yml"

configure do
  set :root, File.dirname(__FILE__)

  # Configure logging
  enable :logging
  file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file

  # Configure sessions and flash
  enable :sessions
  use Rack::Flash

  # Work around rack protection referrer bug
  set :protection, except: :json_csrf

  # Configure ORCID client, scope and site are different from defaults
  use OmniAuth::Builder do
    provider :jwt, ENV['JWT_SECRET_KEY'],
      auth_url: ENV['JWT_URL'],
      uid_claim: 'uid',
      required_claims: ['uid', 'name'],
      info_map: { "name" => "name",
                  "authentication_token" => "authentication_token",
                  "role" => "role" }
  end
  # OmniAuth.config.logger = logger

  # Google analytics event tracking
  set :ga, Gabba::Gabba.new(ENV['GABBA_COOKIE'], ENV['GABBA_URL']) if ENV['GABBA_COOKIE']

  # optionally use Bugsnag for error logging
  if ENV['BUGSNAG_KEY']
    require 'bugsnag'
    Bugsnag.configure do |config|
      config.api_key = ENV['BUGSNAG_KEY']
      config.project_root = settings.root
      config.app_version = App::VERSION
      config.release_stage = ENV['RACK_ENV']
      config.notify_release_stages = %w(production, development)
    end

    use Bugsnag::Rack
    enable :raise_errors
  end
end

after do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

get '/' do
  @title = "Home"
  haml :index
end

get '/status' do
  @title = "Status"
  @process = SidekiqProcess.new
  haml :status
end

get '/agents' do
  @title = "Agents"
  haml :agents
end

get '/auth/jwt/callback' do
  session[:orcid] = request.env["omniauth.auth"]

  redirect to request.env['omniauth.origin'] || params[:origin] || '/'
end

# Used to sign out a user but can also be used to mark that a user has seen the
# 'You have been signed out' message. Clears the user's session cookie.
get '/auth/signout' do
  session.clear
  redirect to('/')
end

get '/auth/failure' do
  flash[:error] = "Authentication failed with message \"#{params['message']}\"."
  haml :auth_callback
end

get '/api/agents' do
  agents = settings.agents.map do |agent|
    { 'id' => agent['name'],
      'type' => 'agent',
      'attributes' => {
        'title' => agent['title'],
        'description' => agent['description']
      } }
  end
  json meta: { 'total' => agents.size }, data: agents
end