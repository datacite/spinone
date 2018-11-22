require 'rails_helper'

describe "Works", type: :request, vcr: true do
  let(:expected_work) { OpenStruct.new(id: "https://handle.test.datacite.org/10.1234/rh5j9bx3gn.1", title: "2018-09-21 07:26:21.58 3 authors public mode (revised)") }

  it "works" do
    get '/works'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["data-centers"].size).to eq(15)
    expect(meta["data-centers"].first).to eq("count"=>10861, "id"=>"tib.aip", "title"=>"Leibniz-Institut für Astrophysik Potsdam (AIP) An der Sternwarte 16 14482 Potsdam")
    expect(meta["registered"].size).to eq(7)
    expect(meta["registered"].first).to eq("id"=>"2018", "title"=>"2018", "count"=>23869)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.1234/rh5j9bx3gn.1")
    expect(work.dig("attributes", "title")).to eq("Title of Mendeley Data Set")
  end

  it "works with page size" do
    get '/works?page[size]=40'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(40)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.1234/rh5j9bx3gn.1")
    expect(work.dig("attributes", "title")).to eq("Title of Mendeley Data Set")
  end

  it "works with sample" do
    get '/works?sample=10'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(10)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.17876/musewide/dr.1/30921")
    expect(work.dig("attributes", "title")).to eq("candels-cdfs-30")
  end

  it "works with sample and sample-group" do
    get '/works?sample=1&sample-group=client&page[size]=10'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(10)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.17876/musewide/dr.1/30921")
    expect(work.dig("attributes", "title")).to eq("candels-cdfs-30")
  end

  it "works with sample and sample-group limit total to 1000" do
    get '/works?sample=50&sample-group=client&page[size]=50'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(1000)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.17876/musewide/dr.1/30921")
    expect(work.dig("attributes", "title")).to eq("candels-cdfs-30")
  end

  # it "works with include data-center" do
  #   get '/works?include=data-center'
  
  #   expect(last_response.status).to eq(200)
  
  #   expect(json["data"].size).to eq(25)
  #   work = json["data"].first
  #   expect(work["id"]).to eq("https://handle.test.datacite.org/10.17863/cam.329")
  #   expect(work.dig("attributes", "title")).to eq("26-hour storage of a declined liver prior to successful transplantation using ex vivo normothermic perfusion")
  
  #   expect(json["included"].size).to eq(4)
  #   data_center = json["included"].first
  #   expect(data_center["id"]).to eq("bl.cam")
  #   expect(data_center.dig("attributes", "title")).to eq("University of Cambridge")
  # end
  
  # it "works with include data-center, member and resource-type" do
  #   get '/works?include=data-center,member,resource-type'
  
  #   expect(last_response.status).to eq(200)
  
  #   expect(json["data"].size).to eq(25)
  #   work = json["data"].first
  #   expect(work["id"]).to eq("https://handle.test.datacite.org/10.17863/cam.329")
  #   expect(work.dig("attributes", "title")).to eq("26-hour storage of a declined liver prior to successful transplantation using ex vivo normothermic perfusion")
  
  #   expect(json["included"].size).to eq(9)
  #   client = json["included"].last
  #   expect(client["id"]).to eq("bl.mendeley")
  #   expect(client.dig("attributes", "title")).to eq("Mendeley Data")
  # end

  it "works with query" do
    get '/works?query=cancer'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.33522/08da-3cnl")
    expect(work.dig("attributes", "title")).to eq("Methods for Measuring Cancer Disparities: Using Data Relevant to Healthy People 2010 Cancer-Related Objectives")
  end

  it "works with query sort by minted" do
    get '/works?query=cancer&sort=minted'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.33522/08da-3cnl")
    expect(work.dig("attributes", "title")).to eq("Methods for Measuring Cancer Disparities: Using Data Relevant to Healthy People 2010 Cancer-Related Objectives")
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

    expect(json["data"].size).to eq(21)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.33540/rry0-5b44")
    expect(work.dig("attributes", "title")).to eq("My test title")
    expect(work.dig("attributes", "url")).to eq("http://datacommons.cyverse.org/browse/iplant/home/shared/commons_repo/curated/doi-test-full-datacite")
  end

  it "works with resource-type dataset" do
    get '/works?resource-type-id=dataset'

    expect(last_response.status).to eq(200)

    expect(json.dig("meta", "total")).to eq(18773)
    expect(json.dig("meta", "total-pages")).to eq(751)
    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.1234/rh5j9bx3gn.1")
    expect(work.dig("attributes", "title")).to eq("Title of Mendeley Data Set")
  end

  it "works with data-center-id" do
    get '/works?data-center-id=bl.mendeley'

    expect(last_response.status).to eq(200)

    expect(json.dig("meta", "total")).to eq(1052)
    expect(json.dig("meta", "total-pages")).to eq(43)
    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq(expected_work.id)
    expect(work.dig("attributes", "title")).to eq("Title of Mendeley Data Set")
  end

  it "works with checked date" do
    get '/works?checked=2018-03-01'

    expect(last_response.status).to eq(200)

    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.1234/rh5j9bx3gn.1")
    expect(work.dig("attributes", "title")).to eq("Title of Mendeley Data Set")
  end
  
  it "works with resource-type dataset and data-center mendeley" do
    get '/works?resource-type-id=dataset&data-center-id=bl.mendeley'
  
    expect(last_response.status).to eq(200)
  
    expect(json.dig("meta", "total")).to eq(1051)
    expect(json.dig("meta", "total-pages")).to eq(43)
    expect(json["data"].size).to eq(25)
    work = json["data"].first
    expect(work["id"]).to eq(expected_work.id)
    expect(work.dig("attributes", "title")).to eq("Title of Mendeley Data Set")
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

  it "work that doesn't exist" do
    get '/works/10.1098/rsif.2017.0030'

    expect(last_response.status).to eq(404)

    errors = json["errors"]
    expect(errors.first.dig("title")).to eq("The resource you are looking for doesn't exist.")
  end

  it "work with + sign in doi" do
    get '/works/10.14454/terra+aqua/ceres/cldtyphist_l3.004'

    expect(last_response.status).to eq(200)

    work = json["data"]
    expect(work["id"]).to eq("https://handle.test.datacite.org/10.14454/terra+aqua/ceres/cldtyphist_l3.004")
    expect(work.dig("attributes", "title")).to eq("CERES Level 3 Cloud Type Historgram Terra+Aqua HDF file - Edition4")
  end
end
