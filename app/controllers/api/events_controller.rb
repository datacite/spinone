class Api::EventsController < Api::BaseController
  swagger_controller :events, "Events"

  swagger_api :index do
    summary 'Returns all events'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns event by id'
    param :path, :id, :string, :required, "Event ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    @events = Event.where(params)
    render json: @events[:data], meta: @events[:meta]
  end

  def show
    @event = Event.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @event.present?

    render json: @event[:data]
  end
end
