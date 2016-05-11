class Api::MembersController < Api::BaseController
  swagger_controller :members, "Members"

  swagger_api :index do
    summary 'Returns all members'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns member by id'
    param :path, :id, :string, :required, "Member ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    @members = Member.where(params)
    render json: @members[:data], meta: @members[:meta]
  end

  def show
    @member = Member.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @member.present?

    render json: @member[:data]
  end
end
