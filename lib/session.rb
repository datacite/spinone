module Sinatra
  module Session
    def current_user
      @current_user ||= session[:auth].present? ? User.new(session[:auth]) : nil
    end

    def current_user=(user)
      @current_user = user
      session[:auth] = user.nil? ? nil : user.auth_hash
    end

    def signed_in?
      !!current_user
    end

    def is_admin_or_staff?
      current_user && current_user.is_admin_or_staff?
    end
  end

  helpers Session
end
