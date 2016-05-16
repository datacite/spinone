class Api::WorksController < Api::BaseController
  swagger_controller :works, "Works"

  swagger_api :index do
    summary 'Returns all works'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns work by id'
    param :path, :id, :string, :required, "Work PID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    collection = Work.where(params)
    render json: collection[:data], meta: collection[:meta]
  end

  def show
    item = Work.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless item.present?

    render json: item[:data]
  end
end
