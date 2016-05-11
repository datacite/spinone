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
    @works = Work.where(params)
    render json: @works[:data], meta: @works[:meta]
  end

  def show
    @work = Work.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @work.present?

    render json: @work[:data]
  end
end
