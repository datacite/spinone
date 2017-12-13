require 'rails_helper'

describe DataCenter, type: :model, vcr: true do
  it "data centers" do
    datacenters = DataCenter.where(page: { size: 50 })[:data]
    expect(datacenters.length).to eq(50)
    datacenter = datacenters.first
    expect(datacenter.name).to eq("027.7 - Zeitschrift für Bibliothekskultur")
  end

  it "data centers with query" do
    datacenters = DataCenter.where(query: "california")[:data]
    expect(datacenters.length).to eq(5)
    datacenter = datacenters.first
    expect(datacenter.name).to eq("California Coastal Atlas")
  end

  it "data centers with registration_agency_id" do
    datacenters = DataCenter.where(registration_agency_id: "datacite")[:data]
    expect(datacenters.length).to eq(25)
    datacenter = datacenters.first
    expect(datacenter.name).to eq("027.7 - Zeitschrift für Bibliothekskultur")
  end

  it "data center" do
    datacenter = DataCenter.where(id: "ETHZ.UBASOJS")[:data]
    expect(datacenter.name).to eq("027.7 - Zeitschrift für Bibliothekskultur")
  end
end
