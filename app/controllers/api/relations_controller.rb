class Api::RelationsController < Api::BaseController
  def index
    @relations = Relation.where(params)
    render jsonapi: @relations[:data], meta: @relations[:meta], include: "relation_type,source"
  end
end
