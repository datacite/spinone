class Api::RegistrationAgenciesController < Api::BaseController
  swagger_controller :registration_agencys, "Registration Agencies"

  swagger_api :index do
    summary 'Returns all registration_agencies'
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :show do
    summary 'Returns registration_agency by id'
    param :path, :id, :string, :required, "Registration agency ID"
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  def index
    @registration_agencys = RegistrationAgency.all
    render json: @registration_agencies[:data], meta: @registration_agencies[:meta]
  end

  def show
    @registration_agency = RegistrationAgency.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @registration_agency.present?

    render json: @registration_agency[:data]
  end
end
