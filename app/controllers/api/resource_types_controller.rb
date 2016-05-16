class Api::ResourceTypesController < Api::BaseController
  swagger_controller :resource_types, "Resource Types"

  swagger_api :index do
    summary 'Returns all resource types'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns resource type by id'
    param :path, :id, :string, :required, "Resource type ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    @resource_types = ResourceType.all
    render json: @resource_types[:data], meta: @resource_types[:meta]
  end

  def show
    @resource_type = ResourceType.find(params[:id])
    fail ActiveRecord::RecordNotFound unless @resource_type.present?

    render json: @resource_type[:data]
  end
end
