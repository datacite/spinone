class Api::PublishersController < Api::BaseController
  def index
    @publishers = Publisher.where(params)
    render jsonapi: @publishers[:data], meta: @publishers[:meta], include: "member,registration_agency"
  end

  def show
    @publisher = Publisher.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @publisher.present?

    render jsonapi: @publisher[:data], include: "member,registration_agency"
  end
end
