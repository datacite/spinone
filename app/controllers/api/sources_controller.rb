class Api::SourcesController < Api::BaseController
  def index
    @sources = Source.where(params)
    fail ActiveRecord::RecordNotFound unless @sources.present?

    render jsonapi: @sources[:data], meta: @sources[:meta], include: ["group"]
  end

  def show
    @source = Source.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @source.present?

    render jsonapi: @source[:data], include: ["group"]
  end
end
