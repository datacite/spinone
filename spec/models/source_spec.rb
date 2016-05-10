require 'rails_helper'

describe Source, type: :model, vcr: true do
  it "sources" do
    sources = Source.all
    expect(sources.length).to eq(6)
    source = sources.first
    expect(source.title).to eq("DataCite (RelatedIdentifier)")
  end

  it "source" do
    source = Source.where(id: "datacite_related")
    expect(source.title).to eq("DataCite (RelatedIdentifier)")
  end
end
