class Api::RelationsController < Api::BaseController
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
    @relations = Relation.where(params)
    render jsonapi: @relations[:data], meta: @relations[:meta], include: @include
  end
end
