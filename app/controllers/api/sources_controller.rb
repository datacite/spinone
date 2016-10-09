class Api::SourcesController < Api::BaseController
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
    @sources = Source.where(params)
    fail ActiveRecord::RecordNotFound unless @sources.present?

    render jsonapi: @sources[:data], meta: @sources[:meta], include: @include
  end

  def show
    @source = Source.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @source.present?

    render jsonapi: @source[:data], include: @include
  end
end
