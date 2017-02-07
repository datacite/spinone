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
require "capybara/poltergeist"
require "capybara-screenshot/rspec"
require "webmock/rspec"
require "rack/test"
require "colorize"
require "maremma"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    timeout: 180,
    inspector: true,
    debug: false,
    window_size: [1024, 768]
  })
end

Capybara.javascript_driver = :poltergeist
Capybara.default_selector = :css

Capybara.configure do |config|
  config.match = :prefer_exact
  config.ignore_hidden_elements = true
end

WebMock.disable_net_connect!(
  allow: ['codeclimate.com:443', ENV['PRIVATE_IP'], ENV['HOSTNAME']],
  allow_localhost: true
)

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_hosts "codeclimate.com"
  c.filter_sensitive_data("<ORCID_CLIENT_ID>") { ENV["ORCID_CLIENT_ID"] }
  c.filter_sensitive_data("<ORCID_CLIENT_SECRET>") { ENV["ORCID_CLIENT_SECRET"] }
  c.filter_sensitive_data("<ORCID_AUTHENTICATION_TOKEN>") { ENV["ORCID_AUTHENTICATION_TOKEN"] }
  c.filter_sensitive_data("<LAGOTTO_TOKEN>") { ENV["LAGOTTO_TOKEN"] }
  c.filter_sensitive_data("<VOLPINO_TOKEN>") { ENV["VOLPINO_TOKEN"] }
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

  # restore application-specific ENV variables after each example
  config.after(:each) do
    ENV_VARS.each { |k,v| ENV[k] = v }
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
