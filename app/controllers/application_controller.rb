class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include ApplicationHelper

  before_filter :miniprofiler

  helper_method :current_user

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, :alert => exception.message
  end

  private

  def miniprofiler
    Rack::MiniProfiler.authorize_request if current_user && current_user.is_admin?
  end
end
