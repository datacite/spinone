class MembersController < ApplicationController
  def index
    @members = Member.where(params)

    options = {}
    options[:meta] = @members[:meta]

    @members = @members[:data]

    render json: MemberSerializer.new(@members, options).serialized_json, status: :ok
  end

  def show
    @member = Member.where(id: params[:id])
    fail AbstractController::ActionNotFound unless @member.present?

    @member = @member[:data]

    render json: MemberSerializer.new(@member).serialized_json, status: :ok
  end
end
