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
    expect(page["id"]).to eq("https://doi.org/10.5438/d5zg-9g02")
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
    expect(page["id"]).to eq("https://doi.org/10.5438/spfw-5q39")
    expect(page.dig("attributes", "title")).to eq("Next steps for the Organization ID Initiative: Report from the Stakeholder Meeting")
  end

  it "pages page 2" do
    get '/pages?page[number]=2'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["total"]).to eq(87)
    expect(meta["tags"].size).to eq(15)
    expect(meta["tags"].first).to eq(["datacite", 19])

    expect(json["data"].size).to eq(25)
    page = json["data"].first
    expect(page["id"]).to eq("https://doi.org/10.5438/zwsf-4y7y")
    expect(page.dig("attributes", "title")).to eq("2016 in review")
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
    expect(page["id"]).to eq("https://doi.org/10.5438/spfw-5q39")
    expect(page.dig("attributes", "title")).to eq("Next steps for the Organization ID Initiative: Report from the Stakeholder Meeting")
  end

  it "single page" do
    get '/pages/10.5438/zwsf-4y7y'

    expect(last_response.status).to eq(200)

    page = json["data"]
    expect(page["id"]).to eq("https://doi.org/10.5438/zwsf-4y7y")
    expect(page.dig("attributes", "title")).to eq("2016 in review")
  end
end
