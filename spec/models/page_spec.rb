require 'rails_helper'

describe Page, type: :model, vcr: true do
  it "pages" do
    pages = Page.all[:data]
    expect(pages.length).to eq(25)
    page = pages.first
    expect(page.title).to eq("New DataCite Metadata Schema 4.0")
  end

  it "page" do
    page = Page.where(id: "blog.datacite.org/new-metadata-schema-4-0")[:data]
    expect(page.title).to eq("New DataCite Metadata Schema 4.0")
  end
end
