class Api::PublishersController < Api::BaseController
  def index
    @publishers = Publisher.where(params)
    render json: @publishers[:data], meta: @publishers[:meta]
  end

  def show
    @publisher = Publisher.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @publisher.present?

    render json: @publisher[:data]
  end
end
