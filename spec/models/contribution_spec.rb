require 'rails_helper'

describe Contribution, type: :model, vcr: true do
  it "contributions" do
    contributions = Contribution.where(rows: 50)[:data]
    contribution = contributions.first
    expect(contribution.credit_name).to eq("Wenfa Ng")
    expect(contribution.is_a?(Contribution)).to eq(true)
    last = contributions.last
    expect(last.is_a?(Member)).to eq(true)
  end

  it "contributions with filter by source" do
    contributions = Contribution.where("source-id" => "datacite-search-link")[:data]
    first = contributions.first
    expect(first.title).to eq("CrowdoMeter Tweet Classifications")
    expect(first.is_a?(Contribution)).to eq(true)
  end

  it "contributions with publishers" do
    contributions = Contribution.where("publisher-id" => "tib.pangaea")[:data]
    publisher = contributions[-2]
    expect(publisher.is_a?(Publisher)).to eq(true)
  end

end
