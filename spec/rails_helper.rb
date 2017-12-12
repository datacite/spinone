# set ENV variables for testing
ENV["RAILS_ENV"] = "test"
ENV["MODE"] = "datacite"
ENV["API_KEY"] = "12345"

# set up Code Climate
require "codeclimate-test-reporter"
CodeClimate::TestReporter.configure do |config|
  config.logger.level = Logger::WARN
end
CodeClimate::TestReporter.start

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "shoulda-matchers"
require "email_spec"
require "capybara/rspec"
require "capybara/rails"
require "webmock/rspec"
require "rack/test"
require "colorize"
require "maremma"

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
  config.fixture_path = "#{::Rails.root}/spec/fixtures/"

  # config.include WebMock::API
  config.include Rack::Test::Methods, :type => :api
  config.include Rack::Test::Methods, :type => :controller

  def app
    Rails.application
  end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end
end
