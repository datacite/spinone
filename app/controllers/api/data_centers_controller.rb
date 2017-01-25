class Api::DataCentersController < Api::BaseController
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
    @data_centers = DataCenter.where(params)
    render jsonapi: @data_centers[:data], meta: @data_centers[:meta], include: @include
  end

  def show
    @data_center = DataCenter.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @data_center.present?

    render jsonapi: @data_center[:data], include: @include
  end
end
