class Api::SourcesController < Api::BaseController
  def index
    @sources = Source.all
    render json: @sources[:data], meta: @sources[:meta]
  end

  def show
    @source = Source.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @source.present?

    render json: @source[:data]
  end
end
