class Api::RelationsController < Api::BaseController
  def index
    @relations = Relation.where(params)
    render json: @relations[:data], meta: @relations[:meta]
  end
end
