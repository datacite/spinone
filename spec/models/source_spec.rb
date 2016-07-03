require 'rails_helper'

describe Source, type: :model, vcr: true do
  it "sources" do
    sources = Source.all[:data]
    expect(sources.length).to eq(19)
    source = sources.first
    expect(source.title).to eq("Crossref (DataCite)")
  end

  it "source" do
    sources = Source.where(id: "datacite_related")[:data]
    expect(sources.first.title).to eq("DataCite (RelatedIdentifier)")
  end
end
