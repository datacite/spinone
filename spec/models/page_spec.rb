require 'rails_helper'

describe Page, type: :model, vcr: true do
  it "pages" do
    pages = Page.all[:data]
    expect(pages.length).to eq(25)
    page = pages.first
    expect(page.title).to eq("Wellcome explains the benefits of developing an open and global grant identifier")
  end

  it "query" do
    pages = Page.where(query: "thor")[:data]
    expect(pages.length).to eq(4)
    page = pages.first
    expect(page.title).to eq("Wellcome explains the benefits of developing an open and global grant identifier")
  end
end
