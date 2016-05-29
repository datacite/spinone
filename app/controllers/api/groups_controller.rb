class Api::GroupsController < Api::BaseController
  def index
    @groups = Group.all
    render json: @groups[:data], meta: @groups[:meta]
  end

  def show
    @group = Group.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @group.present?

    render json: @group[:data]
  end
end
