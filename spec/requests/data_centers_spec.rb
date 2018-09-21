require 'rails_helper'

describe "DataCenters", type: :request, vcr: true do
  it "data centers" do
    get '/data-centers'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["total"]).to eq(1508)
    expect(meta["members"].size).to eq(15)
    expect(meta["members"].first).to eq("id"=>"cdl", "title"=>"California Digital Library", "count"=>235)
    expect(meta["years"].size).to eq(9)
    expect(meta["years"].first).to eq("count"=>6, "id"=>"2010", "title"=>"2010")

    expect(json["data"].size).to eq(25)
    data_center = json["data"].first
    expect(data_center["id"]).to eq("ethz.ubasojs")
    expect(data_center.dig("attributes", "title")).to eq("027.7 - Zeitschrift für Bibliothekskultur")
  end

  it "data centers with query" do
    get '/data-centers?query=california'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["total"]).to eq(5)
    expect(meta["members"].size).to eq(2)
    expect(meta["members"].first).to eq("id"=>"cdl", "title"=>"California Digital Library", "count"=>4)
    expect(meta["years"].size).to eq(4)
    expect(meta["years"].first).to eq("count"=>1, "id"=>"2012", "title"=>"2012")

    expect(json["data"].size).to eq(5)
    data_center = json["data"].first
    expect(data_center["id"]).to eq("cdl.ucsdcca")
    expect(data_center.dig("attributes", "title")).to eq("California Coastal Atlas")
  end

  it "data center" do
    get '/data-centers/ethz.ubasojs'

    expect(last_response.status).to eq(200)

    data_center = json["data"]
    expect(data_center["id"]).to eq("ethz.ubasojs")
    expect(data_center.dig("attributes", "title")).to eq("027.7 - Zeitschrift für Bibliothekskultur")
  end
end
