class IndexController < ApplicationController
  def routing_error
    fail AbstractController::ActionNotFound
  end

  def method_not_allowed
    response.set_header('Allow', 'POST')
    render json: { "message": "This endpoint only supports POST requests." }.to_json, status: :method_not_allowed
  end
end
