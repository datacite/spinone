class DatasetsController < ApplicationController
  before_action :set_include

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

    options = {}
    options[:meta] = @works[:meta]
    options[:include] = @include

    @works = @works[:data]

    render json: DatasetSerializer.new(@works, options).serialized_json, status: :ok
  end

  def show
    @work = Work.where(id: params[:id])
    fail AbstractController::ActionNotFound unless @work.present?

    options = {}
    options[:include] = @include

    @work = @work[:data]

    render json: DatasetSerializer.new(@work, options).serialized_json, status: :ok
  end
end
