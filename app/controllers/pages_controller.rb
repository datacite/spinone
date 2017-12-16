class PagesController < ApplicationController
  def index
    @pages = Page.where(params)
    render jsonapi: @pages[:data], meta: @pages[:meta]
  end

  def show
    @page = Page.where(id: params[:id])
    fail AbstractController::ActionNotFound unless @page.present?

    render jsonapi: @page[:data]
  end
end
