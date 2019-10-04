class IndexController < ApplicationController
  def index
    meta = { meta: { name: ENV['SITE_TITLE'] }}.to_json
    render json: meta
  end

  def routing_error
    fail AbstractController::ActionNotFound
  end

  def method_not_allowed
    response.set_header('Allow', 'POST')
    render json: { "message": "This endpoint only supports POST requests." }.to_json, status: :method_not_allowed
  end
end
