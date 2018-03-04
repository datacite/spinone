class PagesController < ApplicationController
  def index
    @pages = Page.where(params)

    options = {}
    options[:meta] = @pages[:meta]

    @pages = @pages[:data]

    render json: PageSerializer.new(@pages, options).serialized_json, status: :ok
  end

  def show
    @page = Page.where(id: params[:id])
    fail AbstractController::ActionNotFound unless @page.present?

    @page = @page[:data]

    render json: PageSerializer.new(@page).serialized_json, status: :ok
  end
end
