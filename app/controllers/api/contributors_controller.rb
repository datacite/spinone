class Api::ContributorsController < Api::BaseController
  def index
    @contributors = Contributor.where(params)
    fail ActiveRecord::RecordNotFound unless @contributors.present?

    render json: @contributors[:data], meta: @contributors[:meta]
  end

  def show
    @contributors = Contributor.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @contributors.present?

    render json: @contributors[:data]
  end
end
