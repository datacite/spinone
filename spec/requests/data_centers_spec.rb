require 'rails_helper'

describe "DataCenters", type: :request, vcr: true do
  it "data centers" do
    get '/data-centers'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["total"]).to eq(1445)
    expect(meta["members"].size).to eq(63)
    expect(meta["members"].first).to eq("id"=>"CDL", "title"=>"California Digital Library", "count"=>235)
    expect(meta["years"].size).to eq(9)
    expect(meta["years"].first).to eq("id"=>"2018", "title"=>"2018", "count"=>53)

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
    expect(meta["members"].first).to eq("id"=>"CDL", "title"=>"California Digital Library", "count"=>4)
    expect(meta["years"].size).to eq(4)
    expect(meta["years"].first).to eq("id"=>"2016", "title"=>"2016", "count"=>2)

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
