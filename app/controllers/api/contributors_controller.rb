class Api::ContributorsController < Api::BaseController
  def index
    @contributors = Person.where(params)
    render jsonapi: @contributors[:data], meta: @contributors[:meta]
  end

  def show
    @contributor = Person.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @contributor.present?

    render jsonapi: @contributor[:data]
  end
end
