require 'rails_helper'

describe Contribution, type: :model, vcr: true do
  it "contributions" do
    contributions = Contribution.where(rows: 50)[:data]
    expect(contributions.length).to eq(54)
    contribution = contributions.first
    expect(contribution.credit_name).to eq("Guillaume Rousselet")
    expect(contribution.is_a?(Contribution)).to eq(true)
    source = contributions.last
    expect(source.is_a?(Source)).to eq(true)
  end

  it "contributions with filter by source" do
    contributions = Contribution.where(source_id: "datacite-search-link")[:data]
    source = contributions.last
    expect(source.title).to eq("Github (Contributor)")
    expect(source.is_a?(Source)).to eq(true)
  end
end
