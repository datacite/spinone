class Api::ContributionsController < Api::BaseController
  swagger_controller :contributions, "Contributions"

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
    @contributions = Contribution.where(params)
    render json: @contributions[:data], meta: @contributions[:meta]
  end
end
