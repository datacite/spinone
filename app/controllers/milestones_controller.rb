class MilestonesController < ApplicationController
  def index
    @milestones = Milestone.where(params.merge(github_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))

    options = {}
    options[:meta] = @milestones[:meta]

    @milestones = @milestones[:data]

    render json: MilestoneSerializer.new(@milestones, options).serialized_json, status: :ok
  end

  def show
    @milestone = Milestone.where({ id: params[:id] }.merge(github_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))
    fail AbstractController::ActionNotFound unless @milestone.present?

    @milestone = @milestone[:data]

    render json: MilestoneSerializer.new(@milestone).serialized_json, status: :ok
  end
end
