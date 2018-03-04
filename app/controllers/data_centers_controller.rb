class DataCentersController < ApplicationController
  before_action :set_include

  def index
    @data_centers = DataCenter.where(params)
    @data_centers[:meta]["members"] = @data_centers[:meta].delete "providers"

    options = {}
    options[:meta] = @data_centers[:meta]
    options[:include] = @include

    @data_centers = @data_centers[:data]

    render json: DataCenterSerializer.new(@data_centers, options).serialized_json, status: :ok
  end

  def show
    @data_center = DataCenter.where(id: params[:id])
    fail AbstractController::ActionNotFound unless @data_center.present?

    @data_center = @data_center[:data]

    render json: DataCenterSerializer.new(@data_center).serialized_json, status: :ok
  end

  def set_include
    if params[:include].present?
      @include = params[:include].split(",").map { |i| i.downcase.underscore.to_sym }
    else
      @include = nil
    end
  end
end
