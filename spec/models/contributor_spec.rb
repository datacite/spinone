require 'rails_helper'

describe Contributor, type: :model, vcr: true do
  it "contributors" do
    contributors = Contributor.where(rows: 50)
    expect(contributors.length).to eq(19)
    contributor = contributors.first
    expect(contributor.family).to eq("Arend")
  end

  it "contributors with q" do
    contributors = Contributor.where(q: "0000-0002-4000-4167")
    expect(contributors.length).to eq(1)
    contributor = contributors.first
    expect(contributor.family).to eq("Arend")
  end

  it "contributor" do
    contributor = Contributor.where(id: "http://orcid.org/0000-0002-4000-4167")
    expect(contributor.family).to eq("Arend")
  end
end
