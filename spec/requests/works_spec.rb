require 'rails_helper'

describe "Works", type: :request, vcr: true do
  let(:expected_work) { OpenStruct.new(id: "https://handle.test.datacite.org/10.4124/73nbydxz48.1", title: "Test dataset 020318120825643") }

  it "works" do
    get '/works'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["data-centers"].size).to eq(15)
    expect(meta["data-centers"].first).to eq("id"=>"bl.ccdc", "title"=>"The Cambridge Structural Database", "count"=>4786)
    expect(meta["years"].size).to eq(15)
    expect(meta["years"].first).to eq("id"=>"2018", "title"=>"2018", "count"=>1254)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq(expected_work.id)
    expect(work.dig("attributes", "title")).to eq(expected_work.title)
  end

  it "works with page size" do
    get '/works?page[size]=40'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(40)
    work = json["data"].first
    expect(work["id"]).to eq(expected_work.id)
    expect(work.dig("attributes", "title")).to eq(expected_work.title)
  end

  it "works with sample" do
    get '/works?sample=10'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(10)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.4124/cc8bzg0")
    expect(work.dig("attributes", "title")).to eq("CCDC 248882: Experimental Crystal Structure Determination")
  end

  it "works with sample and sample-group" do
    get '/works?sample=1&sample-group=client&page[size]=10'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(10)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.4124/cc8bzg0")
    expect(work.dig("attributes", "title")).to eq("CCDC 248882: Experimental Crystal Structure Determination")
  end

  it "works with sample and sample-group limit total to 1000" do
    get '/works?sample=50&sample-group=client&page[size]=50'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(809)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.4124/cc8bzg0")
    expect(work.dig("attributes", "title")).to eq("CCDC 248882: Experimental Crystal Structure Determination")
  end

  it "works with include data-center" do
    get '/works?include=data-center'
  
    expect(last_response.status).to eq(200)
  
    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq(expected_work.id)
    expect(work.dig("attributes", "title")).to eq(expected_work.title)
  
    expect(json["included"].size).to eq(5)
    data_center = json["included"].first
    expect(data_center["id"]).to eq("bl.mendeley")
    expect(data_center.dig("attributes", "title")).to eq("Mendeley Data")
  end
  
  it "works with include data-center, member and resource-type" do
    get '/works?include=data-center,member,resource-type'
  
    expect(last_response.status).to eq(200)
  
    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq(expected_work.id)
    expect(work.dig("attributes", "title")).to eq(expected_work.title)
  
    expect(json["included"].size).to eq(11)
    member = json["included"].last
    expect(member["id"]).to eq("bibsys")
    expect(member.dig("attributes", "title")).to eq("BIBSYS")
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

  it "works with query no results" do
    get '/works?query=xxxx'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(0)
    expect(json.dig("meta", "data-centers").size).to eq(0)
  end

  it "works with query url" do
    get '/works?url=*datacite*'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(6)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.4124/a330d8b8-8903-4340-82f9-373883fbf6ae")
    expect(work.dig("attributes", "title")).to eq("Federica - test type sent to datacite - 5_11_1")
    expect(work.dig("attributes", "url")).to eq("http://riswebtest.st-andrews.ac.uk/portal/en/datasets/federica--test-type-sent-to-datacite--5111(a330d8b8-8903-4340-82f9-373883fbf6ae).html")
  end

  it "works with resource-type dataset" do
    get '/works?resource-type-id=dataset'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq(expected_work.id)
    expect(work.dig("attributes", "title")).to eq(expected_work.title)
  end

  it "works with checked date" do
    get '/works?checked=2018-03-01'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq(expected_work.id)
    expect(work.dig("attributes", "title")).to eq(expected_work.title)
  end
  
  it "works with resource-type dataset and data-center mendeley" do
    get '/works?resource-type-id=dataset&data-center-id=bl.mendeley'
  
    expect(last_response.status).to eq(200)
  
    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.4124/73nbydxz48.1")
    expect(work.dig("attributes", "title")).to eq("Test dataset 020318120825643")
  end

  it "related works" do
    doi = "10.1016/j.gca.2010.12.008"
    get "/works?work-id=#{doi}"

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(1)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.1594/ieda/100037")
    expect(work.dig("attributes", "title")).to eq("LauBasin_TUIM05MV_Mottl")
  end

  it "work" do
    get '/works/10.4124/9f7xnnys8c.5'

    expect(last_response.status).to eq(200)

    work = json["data"]
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.4124/9f7xnnys8c.5")
    expect(work.dig("attributes", "title")).to eq("DAT-3025 Maintain file ordering for published datasets - 4")
  end
end
