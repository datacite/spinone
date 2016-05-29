class Api::ResourceTypesController < Api::BaseController
  def index
    @resource_types = ResourceType.all
    render json: @resource_types[:data], meta: @resource_types[:meta]
  end

  def show
    @resource_type = ResourceType.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @resource_type.present?

    render json: @resource_type[:data]
  end
end
