class Api::EventsController < Api::BaseController
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
