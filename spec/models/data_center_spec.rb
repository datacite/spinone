require 'rails_helper'

describe DataCenter, type: :model, vcr: true do
  it "publishers" do
    publishers = DataCenter.where(rows: 50)[:data]
    expect(publishers.length).to eq(50)
    publisher = publishers.first
    expect(publisher.title).to eq("027.7 - Zeitschrift für Bibliothekskultur")
  end

  it "publishers with query" do
    publishers = DataCenter.where(query: "plos")[:data]
    expect(publishers.length).to eq(1)
    publisher = publishers.first
    expect(publisher.title).to eq("Public Library of Science (PLoS)")
  end

  it "publishers with registration_agency_id" do
    publishers = DataCenter.where(registration_agency_id: "datacite")[:data]
    expect(publishers.length).to eq(25)
    publisher = publishers.first
    expect(publisher.title).to eq("027.7 - Zeitschrift für Bibliothekskultur")
  end

  it "publisher" do
    publisher = DataCenter.where(id: "ETHZ.UBASOJS")[:data]
    expect(publisher.title).to eq("027.7 - Zeitschrift für Bibliothekskultur")
  end
end
