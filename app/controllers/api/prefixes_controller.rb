class Api::PrefixesController < Api::BaseController
  def show
    @prefix = Prefix.where(id: params[:id])
    fail AbstractController::ActionNotFound unless @prefix.present?

    render jsonapi: @prefix[:data]
  end
end
