class UserStoriesController < ApplicationController
  def index
    @user_stories = UserStory.where(params)

    options = {}
    options[:meta] = @user_stories[:meta]

    @user_stories = @user_stories[:data]

    render json: UserStorySerializer.new(@user_stories, options).serialized_json, status: :ok
  end

  def show
    @user_story = UserStory.where(id: params[:id])
    fail AbstractController::ActionNotFound unless @user_story.present?

    @user_story = @user_story[:data]

    render json: UserStorySerializer.new(@user_story).serialized_json, status: :ok
  end
end
