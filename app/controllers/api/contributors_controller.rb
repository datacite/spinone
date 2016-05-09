class Api::ContributorsController < Api::BaseController
  swagger_controller :contributors, "Contributors"

  swagger_api :index do
    summary 'Returns all contributors'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns contributor by id'
    param :path, :id, :string, :required, "Contributor ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

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
