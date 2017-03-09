require 'rails_helper'

describe Prefix, type: :model, vcr: true do
  it "datacite" do
    prefix = Prefix.where(id: "10.5061")[:data]
    expect(prefix.registration_agency).to eq("DataCite")
  end
end
