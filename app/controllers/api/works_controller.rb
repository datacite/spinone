class Api::WorksController < Api::BaseController
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
    @works = Work.where(params)
    render jsonapi: @works[:data], meta: @works[:meta], include: @include
  end

  def show
    @work = Work.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @work.present?

    render jsonapi: @work[:data], include: @include
  end
end
