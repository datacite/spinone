class Api::ContributionsController < Api::BaseController
  before_filter :set_include

  def set_include
    if params[:include].present?
      @include = params[:include].split(",").map { |i| i.downcase.underscore }.join(",")
      @include = [@include]
    else
      @include = nil
    end
  end

  def index
    @contributions = Contribution.where(params)
    render jsonapi: @contributions[:data], meta: @contributions[:meta], include: @include
  end
end
