require 'spec_helper'

describe '/api/status' do
  it "get status" do
    get '/api/status'

    response = ::JSON.parse(last_response.body)
    data = response.fetch('data', {})
    status = data.first
    expect(status['type']).to eq("status")
  end

  it "returns correct content_type" do
    get '/api/status'

    expect(last_response.header["Content-Type"]).to eq("application/vnd.api+json")
  end
end

describe '/api/agents' do
  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8))
    Orcid.new.count = 0
  end

  let(:token) { ENV['ORCID_TOKEN'] }
  let(:uuid) { "33dbf610-c879-4b3d-9f11-3d2505fad194" }
  let(:agent) { Orcid.new }
  let(:headers) do
    { "CONTENT_TYPE" => "application/vnd.api+json",
      "HTTP_AUTHORIZATION" => "Token token=#{token}" }
  end
  let(:params) do
    { "deposit" => { "id" => uuid,
                     "state" => "done",
                     "errors" => nil,
                     "message_type" => agent.source_id,
                     "message_action" => "create",
                     "source_token" => agent.uuid,
                     "total" => 12,
                     "timestamp" => Time.now.iso8601 } }
  end

  it "get returns correct content_type get" do
    get '/api/agents'

    expect(last_response.header["Content-Type"]).to eq("application/vnd.api+json")
  end

  it "post returns correct content_type" do
    post '/api/agents', params.to_json, headers

    expect(last_response.header["Content-Type"]).to eq("application/vnd.api+json")
  end

  it "get agents" do
    get '/api/agents'

    response = ::JSON.parse(last_response.body)
    data = response.fetch('data', {})
    expect(data.length).to eq(3)
    agent = data.first
    expect(agent['type']).to eq("agent")
    expect(agent['attributes']['title']).to eq("ORCID")
  end

  it "post agents" do
    post '/api/agents', params.to_json, headers

    response = ::JSON.parse(last_response.body)
    attributes = response.fetch('data', {}).fetch('attributes', {})
    expect(attributes['state']).to eq("done")
    expect(attributes['source_token']).to eq(agent.uuid)
    expect(agent.count).to eq(12)
  end

  it "post agents no token" do
    headers = { "CONTENT_TYPE" => "application/vnd.api+json" }
    post '/api/agents', params.to_json, headers

    response = ::JSON.parse(last_response.body)
    expect(response['errors']).to eq([{"status"=>401, "title"=>"You are not authorized to access this page"}])
    expect(agent.count).to eq(0)
  end

  it "post agents wrong token" do
    headers = { "CONTENT_TYPE" => "application/vnd.api+json",
                "HTTP_AUTHORIZATION" => "Token token=456" }
    post '/api/agents', params.to_json, headers

    response = ::JSON.parse(last_response.body)
    expect(response['errors']).to eq([{"status"=>401, "title"=>"You are not authorized to access this page"}])
    expect(agent.count).to eq(0)
  end

  it "post agents failed" do
    params = { "deposit" => { "id" => uuid,
                              "state" => "failed",
                              "message_type" => agent.source_id,
                              "message_action" => "failed",
                              "message_size" =>  2,
                              "source_token" => agent.uuid,
                              "timestamp" => "2016-01-09T09:15:18Z" } }
    post '/api/agents', params.to_json, headers

    response = ::JSON.parse(last_response.body)
    expect(response['errors']).to eq([{"status"=>400, "title"=>"Processing of deposit #{uuid} failed"}])
    expect(agent.count).to eq(0)
  end

  it "post agents other state" do
    params = { "deposit" => { "id" => uuid,
                              "state" => "working",
                              "message_type" => agent.source_id,
                              "message_action" => "failed",
                              "message_size" => 12,
                              "source_token" => agent.uuid,
                              "timestamp" => "2016-01-09T09:15:18Z" } }
    post '/api/agents', params.to_json, headers

    response = ::JSON.parse(last_response.body)
    expect(response['errors']).to eq([{"status"=>422, "title"=>"Request must contain state \"done\" or \"failed\""}])
    expect(agent.count).to eq(0)
  end
end
