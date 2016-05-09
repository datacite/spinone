require 'rails_helper'

describe Publisher, type: :model, vcr: true do
  it "publishers" do
    publishers = Publisher.where(rows: 50)
    expect(publishers.length).to eq(50)
    publisher = publishers.first
    expect(publisher.title).to eq("027.7 - Zeitschrift für Bibliothekskultur")
  end

  it "publishers with q" do
    publishers = Publisher.where(q: "plos")
    expect(publishers.length).to eq(1)
    publisher = publishers.first
    expect(publisher.title).to eq("Public Library of Science (PLoS)")
  end

  it "publishers with registration_agency_id" do
    publishers = Publisher.where(registration_agency_id: "datacite")
    expect(publishers.length).to eq(1)
    publisher = publishers.first
    expect(publisher.title).to eq("Public Library of Science (PLoS)")
  end

  it "publisher" do
    publisher = Publisher.where(id: "ETHZ.UBASOJS")
    expect(publisher.title).to eq("027.7 - Zeitschrift für Bibliothekskultur")
  end
end
