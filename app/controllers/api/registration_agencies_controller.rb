class Api::RegistrationAgenciesController < Api::BaseController
  def index
    @registration_agencies = RegistrationAgency.all
    render jsonapi: @registration_agencies[:data], meta: @registration_agencies[:meta]
  end

  def show
    @registration_agency = RegistrationAgency.where(id: params[:id])
    fail ActiveRecord::RecordNotFound unless @registration_agency.present?

    render jsonapi: @registration_agency[:data]
  end
end
