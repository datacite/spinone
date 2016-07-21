# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
  key: ENV['SESSION_KEY'],
  secure: Rails.env.production?,
  domain: :all,
  expire_after: 14.days
