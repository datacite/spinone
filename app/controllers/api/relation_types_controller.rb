class Api::RelationTypesController < Api::BaseController
  swagger_controller :relation_types, "Relation Types"

  swagger_api :index do
    summary 'Returns all relation types'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns relation type by id'
    param :path, :id, :string, :required, "Relation type ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    @relation_types = RelationType.all
    render json: @relation_types[:data], meta: @relation_types[:meta]
  end

  def show
    @relation_type = RelationType.find(params[:id])
    fail ActiveRecord::RecordNotFound unless @relation_type.present?

    render json: @relation_type[:data]
  end
end
