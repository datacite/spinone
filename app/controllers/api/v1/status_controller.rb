class Api::V1::StatusController < Api::BaseController
  before_filter :authenticate_user_from_token!

  swagger_controller :status, "Status"

  swagger_api :index do
    summary "Returns status information"
    notes "Status information is generated every hour. Returns 1,000 results per page."
    param :query, :page, :integer, :optional, "Page number"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    Status.create unless Status.count > 0
    page = params[:page] || { number: 1, size: 1000 }
    @status = Status.all.order("created_at DESC").page(page[:number]).per_page(page[:size])
    meta = { total: @status.total_entries, 'total-pages' => @status.total_pages , page: page[:number].to_i }
    render json: @status, meta: meta
  end
end
