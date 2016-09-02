# adapted from https://github.com/mperham/sidekiq/wiki/Monitoring

require "jwt"

class AuthConstraint
  def self.admin?(request)
    cookie = request.cookie_jar['jwt']
    return false unless cookie.present?

    user = User.new((JWT.decode cookie, ENV['JWT_SECRET_KEY']).first)
    user.is_admin_or_staff?
  end
end
