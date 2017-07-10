require 'rails_helper'

describe Page, type: :model, vcr: true do
  it "pages" do
    pages = Page.all[:data]
    expect(pages.length).to eq(25)
    page = pages.first
    expect(page.title).to eq("Development Roadmap")
  end

  it "query" do
    pages = Page.where(query: "thor")[:data]
    expect(pages.length).to eq(14)
    page = pages.first
    expect(page.title).to eq("A Content Negotiation Update")
  end

  it "page" do
    page = Page.where(id: "10.5438/PE54-ZJ5T")[:data]
    expect(page.title).to eq("It's all about Relations")
  end
end
