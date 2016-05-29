class Api::RegistrationAgenciesController < Api::BaseController
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
