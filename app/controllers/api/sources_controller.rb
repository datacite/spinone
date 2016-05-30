class Api::SourcesController < Api::BaseController
  def index
    @sources = Source.where(params)
    fail ActiveRecord::RecordNotFound unless @sources.present?

    render json: @sources[:data], meta: @sources[:meta]
  end

  def show
    @source = Source.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @source.present?

    render json: @source[:data]
  end
end
