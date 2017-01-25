class Api::PublishersController < Api::BaseController
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
    @publishers = DataCenter.where(params)
    render jsonapi: @publishers[:data], meta: @publishers[:meta], include: @include
  end

  def show
    @publisher = DataCenter.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @publisher.present?

    render jsonapi: @publisher[:data], include: @include
  end
end
