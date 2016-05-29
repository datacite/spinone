class Api::WorksController < Api::BaseController
  def index
    collection = Work.where(params)
    render json: collection[:data], meta: collection[:meta]
  end

  def show
    item = Work.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless item.present?

    render json: item[:data]
  end
end
