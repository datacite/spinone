require 'rails_helper'

describe Page, type: :model, vcr: true do
  it "pages" do
    pages = Page.all[:data]
    expect(pages.length).to eq(25)
    page = pages.first
    expect(page.title).to eq("DOI Registrations for Software")
  end

  it "query" do
    pages = Page.where(query: "thor")[:data]
    expect(pages.length).to eq(5)
    page = pages.first
    expect(page.title).to eq("PIDs for conferences - your comments are welcome!")
  end
end
