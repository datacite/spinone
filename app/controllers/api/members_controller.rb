class Api::MembersController < Api::BaseController
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
