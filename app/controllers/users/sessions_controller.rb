class Users::SessionsController < Devise::OmniauthCallbacksController
  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    sign_out current_user
    redirect_to "#{ENV['JWT_HOST']}/sign_out?id=#{ENV['JWT_NAME']}"
  end
end
