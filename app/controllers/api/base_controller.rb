class Api::BaseController < ActionController::Base
  # include base controller methods
  include Authenticable

  before_filter :default_format_json
  after_filter :cors_set_access_control_headers, :set_jsonp_format

  attr_reader :current_user

  # from https://github.com/spree/spree/blob/master/api/app/controllers/spree/api/base_controller.rb
  def set_jsonp_format
    if params[:callback] && request.get?
      self.response_body = "#{params[:callback]}(#{response.body})"
      headers["Content-Type"] = 'application/javascript'
    end
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def authenticate_user_from_token!
    token = token_from_request_headers
    raise CanCan::AccessDenied unless token.present?

    payload = decode_token(token)
    raise CanCan::AccessDenied unless payload.present?

    # create user from token
    @current_user = User.new(payload)
  end

  # from https://github.com/nsarno/knock/blob/master/lib/knock/authenticable.rb
  def token_from_request_headers
    unless request.headers['Authorization'].nil?
      request.headers['Authorization'].split.last
    end
  end

  unless Rails.env.development?
    rescue_from *RESCUABLE_EXCEPTIONS do |exception|
      status = case exception.class.to_s
               when "CanCan::AccessDenied", "JWT::DecodeError" then 401
               when "AbstractController::ActionNotFound", "ActionController::RoutingError" then 404
               when "ActiveModel::ForbiddenAttributesError", "ActionController::UnpermittedParameters", "NoMethodError" then 422
               else 400
               end

      if status == 404
        message = "The page you are looking for doesn't exist."
      elsif status == 401
        message = "You are not authorized to access this page."
      else
        message = exception.message
      end

      respond_to do |format|
        format.all { render json: { errors: [{ status: status.to_s,
                                               title: message }]
                                  }, status: status
                   }
      end
    end
  end

  protected

  def is_admin_or_staff?
    current_user && current_user.is_admin_or_staff? ? 1 : 0
  end
end
