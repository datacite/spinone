class UserStoriesController < ApplicationController
  def index
    @user_stories = UserStory.where(params.merge(github_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))
    render jsonapi: @user_stories[:data], meta: @user_stories[:meta]
  end

  def show
    @user_story = UserStory.where({ id: params[:id] }.merge(github_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN']))
    fail AbstractController::ActionNotFound unless @user_story.present?

    render jsonapi: @user_story[:data]
  end
end
