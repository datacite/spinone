class Api::EventsController < Api::BaseController
  def index
    @events = Event.where(params)
    render jsonapi: @events[:data], meta: @events[:meta]
  end

  def show
    @event = Event.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @event.present?

    render jsonapi: @event[:data]
  end
end
