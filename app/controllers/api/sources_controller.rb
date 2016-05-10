class Api::SourcesController < Api::BaseController
  swagger_controller :sources, "Sources"

  swagger_api :index do
    summary 'Returns all sources'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns source by id'
    param :path, :id, :string, :required, "Source ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

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
