class Api::RelationTypesController < Api::BaseController
  def index
    @relation_types = RelationType.all
    render jsonapi: @relation_types[:data], meta: @relation_types[:meta]
  end

  def show
    @relation_type = RelationType.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @relation_type.present?

    render jsonapi: @relation_type[:data]
  end
end
