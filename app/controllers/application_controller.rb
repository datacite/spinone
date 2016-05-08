class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user

  def after_sign_in_path_for(resource)
    if resource.created_at > 1.minute.ago
      '/users/me'
    else
      request.env['omniauth.origin'].presence || stored_location_for(resource) || '/users/me'
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, :alert => exception.message
  end
end
