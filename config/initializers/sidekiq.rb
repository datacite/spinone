require 'resolv-replace.rb'

Sidekiq.configure_server do |config|
  config.options[:concurrency] = ENV["CONCURRENCY"].to_i
end
