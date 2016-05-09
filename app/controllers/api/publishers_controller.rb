class Api::PublishersController < Api::BaseController
  swagger_controller :publishers, "Publishers"

  swagger_api :index do
    summary 'Returns all publishers'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns publisher by id'
    param :path, :id, :string, :required, "Publisher ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    @publishers = Publisher.where(params)
    render json: @publishers, meta: { total: @publishers.length }
  end

  def show
    @publisher = Publisher.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @publisher.present?

    render json: @publisher
  end
end
