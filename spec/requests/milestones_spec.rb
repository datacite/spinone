require 'rails_helper'

describe "Milestones", type: :request, vcr: true do
  it "milestones" do
    get '/milestones'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["total"]).to eq(8)
    expect(json["data"].size).to eq(8)
    page = json["data"].first
    expect(page["id"]).to eq("38")
    expect(page.dig("attributes", "title")).to eq("Public API to manage clients and prefixes")
  end

  it "open milestones" do
    get '/milestones?state=open'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["total"]).to eq(8)
    expect(json["data"].size).to eq(8)
    page = json["data"].first
    expect(page["id"]).to eq("38")
    expect(page.dig("attributes", "title")).to eq("Public API to manage clients and prefixes")
  end

  it "closed milestones" do
    get '/milestones?state=closed'

    expect(last_response.status).to eq(200)

    meta = json["meta"]
    expect(meta["total"]).to eq(24)
    expect(json["data"].size).to eq(24)
    page = json["data"].first
    expect(page["id"]).to eq("27")
    expect(page.dig("attributes", "title")).to eq("Upgraded database infrastructure")
  end
end