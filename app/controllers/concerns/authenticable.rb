module Authenticable
  extend ActiveSupport::Concern

  included do
    def default_format_json
      request.format = :json if request.format.html?
    end

    def authenticate_user_from_token!
      authenticate_with_http_token do |token, options|
        return false unless token.present?

        # create user from token
        current_user = User.new(token)
      end
    end

    unless Rails.env.development?
      rescue_from *RESCUABLE_EXCEPTIONS do |exception|
        status, message = case exception.class.to_s
                          when "AbstractController::ActionNotFound", "ActionController::RoutingError"
                            [404, "The resource you are looking for doesn't exist."]
                          when "ActiveModel::ForbiddenAttributesError", "ActionController::UnpermittedParameters", "ActionController::ParameterMissing"
                            [422, exception.message]
                          when "NoMethodError"
                            Rails.env.development? || Rails.env.test? ? [422, exception.message] : [422, "The request could not be processed."]
                          else
                            [400, exception.message]
                          end

        respond_to do |format|
          format.all { render json: { errors: [{ status: status.to_s,
                                                 title: message }]
                                    }, status: status, content_type: "application/json"
                     }
        end
      end
    end
  end
end
