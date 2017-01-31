require 'rails_helper'

describe Person, type: :model, vcr: true do
  it "contributors" do
    contributors = Person.where(rows: 50)[:data]
    expect(contributors.length).to eq(50)
    contributor = contributors.first
    expect(contributor.literal).to eq("mne-tools")
  end

  it "contributors with query" do
    contributors = Person.where(query: "0000-0002-4000-4167")[:data]
    expect(contributors.length).to eq(1)
    contributor = contributors.first
    expect(contributor.family).to eq("Arend")
  end

  it "contributor" do
    contributor = Person.where(id: "http://orcid.org/0000-0002-4000-4167")[:data]
    expect(contributor.family).to eq("Arend")
  end
end
