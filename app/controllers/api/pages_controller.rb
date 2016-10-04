class Api::PagesController < Api::BaseController
  def index
    @pages = Page.where(params)
    render jsonapi: @pages[:data], meta: @pages[:meta]
  end

  def show
    @page = Page.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @page.present?

    render jsonapi: @page[:data]
  end
end
