require 'rails_helper'

describe Contributor, type: :model, vcr: true do
  it "contributors" do
    contributors = Contributor.where(rows: 50)[:data]
    expect(contributors.length).to eq(50)
    contributor = contributors.first
    expect(contributor.literal).to eq("mne-tools")
  end

  it "contributors with query" do
    contributors = Contributor.where(query: "0000-0002-4000-4167")[:data]
    expect(contributors.length).to eq(1)
    contributor = contributors.first
    expect(contributor.family).to eq("Arend")
  end

  it "contributor" do
    contributor = Contributor.where(id: "http://orcid.org/0000-0002-4000-4167")[:data]
    expect(contributor.family).to eq("Arend")
  end
end
