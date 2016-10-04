class Api::GroupsController < Api::BaseController
  def index
    @groups = Group.all
    render jsonapi: @groups[:data], meta: @groups[:meta]
  end

  def show
    @group = Group.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @group.present?

    render jsonapi: @group[:data]
  end
end
