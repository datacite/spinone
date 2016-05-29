class Api::RelationTypesController < Api::BaseController
  def index
    @relation_types = RelationType.all
    render json: @relation_types[:data], meta: @relation_types[:meta]
  end

  def show
    @relation_type = RelationType.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @relation_type.present?

    render json: @relation_type[:data]
  end
end
