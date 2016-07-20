# From http://blog.carbonfive.com/2016/07/06/rails-meet-phoenix-add-phoenix-to-your-rails-ecosystem-with-session-sharing/
# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: ENV['SESSION_KEY'], domain: :all, tld_length: 2

# These salts are optional, but it doesn't hurt to explicitly configure them the same between apps.
# Rails.application.config.action_dispatch.encrypted_cookie_salt = ENV['SESSION_ENCRYPTED_COOKIE_SALT']
# Rails.application.config.action_dispatch.encrypted_signed_cookie_salt = ENV['SESSION_ENCRYPTED_SIGNED_COOKIE_SALT']
