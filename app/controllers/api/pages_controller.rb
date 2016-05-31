class Api::PagesController < Api::BaseController
  def index
    @pages = Page.where(params)
    fail ActiveRecord::RecordNotFound unless @pages.present?

    render json: @pages[:data], meta: @pages[:meta]
  end

  def show
    @page = Page.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @page.present?

    render json: @page[:data]
  end
end
