# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

# load ENV variables from .env file if it exists
env_file = File.expand_path("../../.env", __FILE__)
if File.exist?(env_file)
  require 'dotenv'
  Dotenv.load! env_file
end

env :PATH, ENV['PATH']
set :environment, ENV['RAILS_ENV']
set :output, "log/cron.log"

# every hour at 5 min past the hour
every "5 * * * *" do
  rake "cron:hourly"
end

every 1.day, at: "5:20 PM" do
  rake "cron:daily"
end

every :monday, at: "1:40 AM" do
  rake "cron:weekly"
end

# every 10th of the month at 2:10 AM
every "50 2 10 * *" do
  rake "cron:monthly"
end
