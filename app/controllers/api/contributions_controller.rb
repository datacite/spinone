class Api::ContributionsController < Api::BaseController
  before_filter :load_contributor, :load_work

  swagger_controller :contributions, "Contributions"

  swagger_api :index do
    summary 'Returns all contributors'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns contributor by id'
    param :path, :id, :string, :required, "Contributor ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    @contributions = Contributor.where(params)
    render json: @contributors[:data], meta: @contributors[:meta]
  end

  protected

  def load_work
    return nil unless params[:work_id].present?

    id_hash = get_id_hash(params[:work_id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @work = Work.where(key => value).first
    else
      @work = nil
    end
    fail ActiveRecord::RecordNotFound unless @work.present?
  end

  def load_contributor
    return nil unless params[:contributor_id].present?
    pid = get_pid(params[:contributor_id])

    @contributor = Contributor.where(pid: pid).first
  end
end
