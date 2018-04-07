require 'rails_helper'

describe "Works", type: :request, vcr: true do
  let(:expected_work) { OpenStruct.new(id: "https://handle.test.datacite.org/10.0133/37522", title: "Dataset O from workspace-1523033259026") }

  it "works" do
    get '/works'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["data_centers"].size).to eq(15)
    expect(meta["data_centers"].first).to eq("id"=>"bl.ccdc", "title"=>"The Cambridge Structural Database", "count"=>4786)
    expect(meta["years"].size).to eq(15)
    expect(meta["years"].first).to eq("id"=>"2018", "title"=>"2018", "count"=>1241)

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
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.22002/d1.208")
    expect(work.dig("attributes", "title")).to eq("Relevant Dates Test")
  end

  it "works with sample and sample-group" do
    get '/works?sample=1&sample-group=client&page[size]=10'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(1)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.22002/d1.208")
    expect(work.dig("attributes", "title")).to eq("Relevant Dates Test")
  end

  it "works with sample and sample-group limit total to 1000" do
    get '/works?sample=50&sample-group=client&page[size]=50'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(50)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.22002/d1.208")
    expect(work.dig("attributes", "title")).to eq("Relevant Dates Test")
  end

  # it "works with include data-center" do
  #   get '/works?include=data-center'
  #
  #   expect(last_response.status).to eq(200)
  #
  #   expect(json["data"].size).to eq(25)
  #   work = json["data"].first
  #   expect(work["id"]).to eq(expected_work.id)
  #   expect(work.dig("attributes", "title")).to eq(expected_work.title)
  #
  #   expect(json["included"].size).to eq(5)
  #   data_center = json["included"].first
  #   expect(data_center["id"]).to eq("bl.f1000r")
  #   expect(data_center.dig("attributes", "title")).to eq("Faculty of 1000 Research")
  # end
  #
  # it "works with include data-center, member and resource-type" do
  #   get '/works?include=data-center,member,resource-type'
  #
  #   expect(last_response.status).to eq(200)
  #
  #   expect(json["data"].size).to eq(25)
  #   work = json["data"].first
  #   expect(work["id"]).to eq(expected_work.id)
  #   expect(work.dig("attributes", "title")).to eq(expected_work.title)
  #
  #   expect(json["included"].size).to eq(11)
  #   resource_type = json["included"].last
  #   expect(resource_type["id"]).to eq("image")
  #   expect(resource_type.dig("attributes", "title")).to eq("Image")
  # end

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
  #
  # it "works with resource-type dataset and data-center mendeley" do
  #   get '/works?resource-type-id=dataset&data-center-id=bl.mendeley'
  #
  #   expect(last_response.status).to eq(200)
  #
  #   expect(json["data"].size).to eq(25)
  #   work = json["data"].first
  #   expect(work["id"]).to eq("https://handle.test.datacite.org/10.4124/rsyr66f522.4")
  #   expect(work.dig("attributes", "title")).to eq("File Types Mendeley Test On 9 Feb 2018 - Version 4 (Published)")
  # end

  it "work" do
    get '/works/10.4124/9f7xnnys8c.5'

    expect(last_response.status).to eq(200)

    work = json["data"]
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.4124/9f7xnnys8c.5")
    expect(work.dig("attributes", "title")).to eq("DAT-3025 Maintain file ordering for published datasets - 4")
  end
end
