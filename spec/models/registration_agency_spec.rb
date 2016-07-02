require 'rails_helper'

describe RegistrationAgency, type: :model, vcr: true do
  it "registration_agencies" do
    registration_agencies = RegistrationAgency.where(rows: 50)[:data]
    expect(registration_agencies.length).to eq(6)
    registration_agency = registration_agencies.first
    expect(registration_agency.title).to eq("Crossref")
  end

  it "registration_agency" do
    registration_agency = RegistrationAgency.where(id: "crossref")[:data]
    expect(registration_agency.title).to eq("Crossref")
  end
end
