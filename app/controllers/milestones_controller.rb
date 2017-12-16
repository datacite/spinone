class MilestonesController < ApplicationController
  def index
    @milestones = Milestone.where(params.merge(github_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))
    render jsonapi: @milestones[:data], meta: @milestones[:meta]
  end

  def show
    @milestone = Milestone.where({ id: params[:id] }.merge(github_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))
    fail AbstractController::ActionNotFound unless @milestone.present?

    render jsonapi: @milestone[:data]
  end
end
