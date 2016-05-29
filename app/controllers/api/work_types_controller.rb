class Api::WorkTypesController < Api::BaseController
  def index
    @work_types = WorkType.all
    render json: @work_types[:data], meta: @work_types[:meta]
  end

  def show
    @work_type = WorkType.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @work_type.present?

    render json: @work_type[:data]
  end
end
