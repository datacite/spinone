class Api::MilestonesController < Api::BaseController
  def index
    @milestones = Milestone.where(params.merge(github_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))
    render jsonapi: @milestones[:data], meta: @milestones[:meta]
  end

  def show
    @milestone = Milestone.where({ id: params[:id] }.merge(github_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))
    fail ActiveRecord::RecordNotFound unless @milestone.present?

    render jsonapi: @milestone[:data]
  end
end
