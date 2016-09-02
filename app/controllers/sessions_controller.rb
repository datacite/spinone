class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    role = auth.extra.raw_info.role || "user"

    # only admin and staff users can sign in
    if ["admin", "staff"].include?(role)
      session[:auth] ||= auth
      redirect_to request.env['omniauth.origin'] || params[:origin] || '/'
    else
      redirect_to root_url, message: "bla"
    end
  end

  def destroy
    session.clear
    redirect_to "#{ENV['JWT_HOST']}/sign_out?id=#{ENV['JWT_NAME']}"
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
