require 'rails_helper'

describe Page, type: :model, vcr: true do
  it "pages" do
    pages = Page.all[:data]
    expect(pages.length).to eq(25)
    page = pages.first
    expect(page.title).to eq("Make Data Count Update: November, 2017")
  end

  it "query" do
    pages = Page.where(query: "thor")[:data]
    expect(pages.length).to eq(14)
    page = pages.first
    expect(page.title).to eq("A Content Negotiation Update")
  end

  it "page" do
    page = Page.where(id: "https://blog.datacite.org/make-data-count-update-november-2017/")[:data]
    expect(page.title).to eq("Make Data Count Update: November, 2017")
  end
end
