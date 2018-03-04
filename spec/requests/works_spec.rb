require 'rails_helper'

describe "Works", type: :request, vcr: true do
  it "works" do
    get '/works'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["data_centers"].size).to eq(15)
    expect(meta["data_centers"].first).to eq("id"=>"bl.ccdc", "title"=>"The Cambridge Structural Database", "count"=>4786)
    expect(meta["years"].size).to eq(15)
    expect(meta["years"].first).to eq("id"=>"2018", "title"=>"2018", "count"=>880)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.0133/36641")
    expect(work.dig("attributes", "title")).to eq("Dataset example")
  end

  it "works with page size" do
    get '/works?page[size]=40'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(40)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.0133/36641")
    expect(work.dig("attributes", "title")).to eq("Dataset example")
  end

  it "works with include data-center" do
    get '/works?include=data-center'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.0133/36641")
    expect(work.dig("attributes", "title")).to eq("Dataset example")

    expect(json["included"].size).to eq(3)
    data_center = json["included"].first
    expect(data_center["id"]).to eq("tib.radar")
    expect(data_center.dig("attributes", "title")).to eq("RADAR Projekt")
  end

  it "works with include data-center, member and resource-type" do
    get '/works?include=data-center,member,resource-type'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.0133/36641")
    expect(work.dig("attributes", "title")).to eq("Dataset example")

    expect(json["included"].size).to eq(9)
    resource_type = json["included"].last
    expect(resource_type["id"]).to eq("image")
    expect(resource_type.dig("attributes", "title")).to eq("Image")
  end

  it "works with query" do
    get '/works?query=cancer'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(8)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.17863/cam.946")
    expect(work.dig("attributes", "title")).to eq("Genome-Wide Meta-Analyses of Breast, Ovarian, and Prostate Cancer Association Studies Identify Multiple New Susceptibility Loci Shared by at Least Two Cancer Types.")
  end

  it "works with query sort by minted" do
    get '/works?query=cancer&sort=minted'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(8)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.17863/cam.946")
    expect(work.dig("attributes", "title")).to eq("Genome-Wide Meta-Analyses of Breast, Ovarian, and Prostate Cancer Association Studies Identify Multiple New Susceptibility Loci Shared by at Least Two Cancer Types.")
  end

  it "works with resource-type dataset" do
    get '/works?resource-type-id=dataset'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.0133/36641")
    expect(work.dig("attributes", "title")).to eq("Dataset example")
  end

  it "works with resource-type dataset and data-center mendeley" do
    get '/works?resource-type-id=dataset&data-center-id=bl.mendeley'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.4124/zrj2z5jxv8.1")
    expect(work.dig("attributes", "title")).to eq("Embargo changer")
  end

  it "work" do
    get '/works/10.4124/9f7xnnys8c.5'

    expect(last_response.status).to eq(200)

    work = json["data"]
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.4124/9f7xnnys8c.5")
    expect(work.dig("attributes", "title")).to eq("DAT-3025 Maintain file ordering for published datasets - 4")
  end
end
