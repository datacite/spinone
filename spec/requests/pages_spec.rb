require 'rails_helper'

describe "Pages", type: :request, vcr: true do
  it "pages" do
    get '/pages'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["total"]).to eq(87)
    expect(meta["tags"].size).to eq(15)
    expect(meta["tags"].first).to eq(["datacite", 19])

    expect(json["data"].size).to eq(25)
    page = json["data"].first
    expect(page["id"]).to eq("https://blog.datacite.org/wellcome-explains-the-benefits-of-developing-an-open-and-global-grant-identifier/")
    expect(page.dig("attributes", "title")).to eq("Wellcome explains the benefits of developing an open and global grant identifier")
  end

  it "pages query" do
    get '/pages?query=orcid'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["total"]).to eq(9)
    expect(meta["tags"].size).to eq(8)
    expect(meta["tags"].first).to eq(["orcid", 8])

    expect(json["data"].size).to eq(9)
    page = json["data"].first
    expect(page["id"]).to eq("https://blog.datacite.org/next-steps/")
    expect(page.dig("attributes", "title")).to eq("Next steps for the Organization ID Initiative: Report from the Stakeholder Meeting")
  end

  it "pages query by tag" do
    get '/pages?tag=orcid'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["total"]).to eq(14)
    expect(meta["tags"].size).to eq(9)
    expect(meta["tags"].first).to eq(["orcid", 14])

    expect(json["data"].size).to eq(14)
    page = json["data"].first
    expect(page["id"]).to eq("https://blog.datacite.org/next-steps/")
    expect(page.dig("attributes", "title")).to eq("Next steps for the Organization ID Initiative: Report from the Stakeholder Meeting")
  end
end
