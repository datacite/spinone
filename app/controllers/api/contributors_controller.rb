class Api::ContributorsController < Api::BaseController
  def index
    @contributors = Contributor.where(params)
    render json: @contributors[:data], meta: @contributors[:meta]
  end

  def show
    @contributor = Contributor.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @contributor.present?

    render json: @contributor[:data]
  end
end
