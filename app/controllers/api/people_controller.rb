class Api::PeopleController < Api::BaseController
  def index
    @people = Person.where(params)
    render jsonapi: @people[:data], meta: @people[:meta]
  end

  def show
    @person = Person.where(id: params[:id])
    fail AbstractController::ActionNotFound unless @person.present?

    render jsonapi: @person[:data]
  end
end
