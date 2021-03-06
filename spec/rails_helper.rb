# set ENV variables for testing
ENV["RAILS_ENV"] = "test"

# set up Code Climate
require 'simplecov'
SimpleCov.start

require File.expand_path('../../config/environment', __FILE__)

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# only load rspec modules that don't use ActiveRecord
require 'rspec/rails/view_rendering'
require 'rspec/rails/matchers'
require 'rspec/rails/file_fixture_support'
require 'rspec/rails/fixture_file_upload_support'
require "shoulda-matchers"
require "webmock/rspec"
require "rack/test"
require "colorize"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

WebMock.disable_net_connect!(
  allow: ['codeclimate.com:443', ENV['PRIVATE_IP'], ENV['HOSTNAME']],
  allow_localhost: true
)

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_hosts "codeclimate.com"
  c.filter_sensitive_data("<GITHUB_PERSONAL_ACCESS_TOKEN>") { ENV["GITHUB_PERSONAL_ACCESS_TOKEN"] }
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  # config.include WebMock::API
  config.include Rack::Test::Methods, :type => :request

  # add custom json method
  config.include RequestSpecHelper, type: :request

  def app
    Rails.application
  end
end
