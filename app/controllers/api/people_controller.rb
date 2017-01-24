class Api::PeopleController < Api::BaseController
  def index
    @people = Contributor.where(params)
    render jsonapi: @people[:data], meta: @people[:meta]
  end

  def show
    @person = Contributor.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @person.present?

    render jsonapi: @person[:data]
  end
end
