require 'rails_helper'

describe Contribution, type: :model, vcr: true do
  it "contributions" do
    result = Contribution.where(rows: 50)
    contributions = result[:data]
    contribution = contributions.first
    expect(contribution.credit_name).to eq("Wenfa Ng")
    expect(contribution.is_a?(Contribution)).to eq(true)
  end

  it "contributions with filter by source" do
    contributions = Contribution.where("source-id" => "datacite-search-link")[:data]
    contribution = contributions.first
    expect(contribution.title).to eq("CrowdoMeter Tweet Classifications")
    expect(contribution.source.title).to eq("DataCite (ORCID Search and Link)")
  end

  it "contributions with publishers" do
    contributions = Contribution.where("publisher-id" => "tib.pangaea")[:data]
    contribution = contributions.first
    expect(contribution.title).to eq("Mixing experiment with 600 g/m**3 silt concentration")
    expect(contribution.publisher.title).to eq("PANGAEA - Publishing Network for Geoscientific and Environmental Data")
  end
end
