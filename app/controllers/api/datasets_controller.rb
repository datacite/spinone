class Api::DatasetsController < Api::BaseController
  def index
    collection = Dataset.where(params)
    fail ActiveRecord::RecordNotFound unless collection.present?

    render json: collection[:data], meta: collection[:meta]
  end

  def show
    item = Dataset.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless item.present?

    render json: item[:data]
  end
end
