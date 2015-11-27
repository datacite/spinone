# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

begin
  # make sure DOTENV is set
  ENV["DOTENV"] ||= "default"

  # load ENV variables from file specified by DOTENV
  # use .env with DOTENV=default
  filename = ENV["DOTENV"] == "default" ? ".env" : ".env.#{ENV['DOTENV']}"

  fail Errno::ENOENT unless File.exist?(File.expand_path("../../#{filename}", __FILE__))

  # load ENV variables from file specified by APP_ENV, fallback to .env
  require "dotenv"
  Dotenv.load! filename
rescue Errno::ENOENT
  $stderr.puts "Please create file .env in the application root folder"
  exit
rescue LoadError
  $stderr.puts "Please install dotenv with \"gem install dotenv\""
  exit
end

env :PATH, ENV['PATH']
env :DOTENV, ENV['DOTENV']
set :environment, ENV['RACK_ENV']
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
