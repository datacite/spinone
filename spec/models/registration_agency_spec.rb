require 'rails_helper'

describe RegistrationAgency, type: :model, vcr: true do
  it "registration_agencies" do
    registration_agencies = RegistrationAgency.where(rows: 50)
    expect(registration_agencies.length).to eq(2)
    registration_agency = registration_agencies.first
    expect(registration_agency.title).to eq("Arend")
  end

  it "registration_agency" do
    registration_agency = RegistrationAgency.where(id: "crossref")
    expect(registration_agency.title).to eq("Arend")
  end
end
