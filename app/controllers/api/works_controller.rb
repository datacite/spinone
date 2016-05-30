class Api::WorksController < Api::BaseController
  def index
    collection = Work.where(params)
    fail ActiveRecord::RecordNotFound unless collection.present?

    render json: collection[:data], meta: collection[:meta]
  end

  def show
    item = Work.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless item.present?

    render json: item[:data]
  end
end
