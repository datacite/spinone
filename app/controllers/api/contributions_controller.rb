class Api::ContributionsController < Api::BaseController
  def index
    @contributions = Contribution.where(params)
    render json: @contributions[:data], meta: @contributions[:meta]
  end
end
