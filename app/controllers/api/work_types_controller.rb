class Api::WorkTypesController < Api::BaseController
  swagger_controller :work_types, "Work Types"

  swagger_api :index do
    summary 'Returns all work types'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns work type by id'
    param :path, :id, :string, :required, "Work type ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    @work_types = WorkType.all
    render json: @work_types[:data], meta: @work_types[:meta]
  end

  def show
    @work_type = WorkType.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @work_type.present?

    render json: @work_type[:data]
  end
end
