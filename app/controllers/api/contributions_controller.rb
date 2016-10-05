class Api::ContributionsController < Api::BaseController
  def index
    @contributions = Contribution.where(params)
    render jsonapi: @contributions[:data], meta: @contributions[:meta], include: "publisher,source"
  end
end
