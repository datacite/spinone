require 'rails_helper'

describe '/api/v1/callbacks', :type => :api do
  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8))
  end

  let(:user) { FactoryGirl.create(:admin_user) }
  let(:token) { user.api_key }
  let(:uuid) { "33dbf610-c879-4b3d-9f11-3d2505fad194" }
  let(:agent) { FactoryGirl.create(:datacite_related) }
  let(:headers) do
    { "CONTENT_TYPE" => "application/json",
      "HTTP_AUTHORIZATION" => "Token token=#{token}" }
  end
  let(:params) do
    { "deposit" => { "id" => uuid,
                     "state" => "done",
                     "errors" => nil,
                     "message_type" => "relation",
                     "message_action" => "create",
                     "source_token" => agent.uuid,
                     "total" => 12,
                     "timestamp" => Time.now.iso8601 } }
  end

  it "post returns correct content_type" do
    post '/api/callbacks', params.to_json, headers

    expect(last_response.header["Content-Type"]).to eq("application/json; charset=utf-8")
  end

  it "post callbacks" do
    post '/api/callbacks', params.to_json, headers

    response = JSON.parse(last_response.body)
    attributes = response.fetch('deposit', {}).fetch('attributes', {})
    expect(attributes['state']).to eq("done")
    expect(attributes['source_token']).to eq(agent.uuid)
    expect(agent.count).to eq(12)
  end

  it "post callbacks no token" do
    headers = { "CONTENT_TYPE" => "application/json" }
    post '/api/callbacks', params.to_json, headers

    response = JSON.parse(last_response.body)
    expect(response).to eq("errors"=>[{"status"=>"401", "title"=>"You are not authorized to access this page."}])
    expect(agent.count).to eq(0)
  end

  it "post callbacks wrong token" do
    headers = { "CONTENT_TYPE" => "application/json",
                "HTTP_AUTHORIZATION" => "Token token=456" }
    post '/api/callbacks', params.to_json, headers

    response = JSON.parse(last_response.body)
    expect(response).to eq("errors"=>[{"status"=>"401", "title"=>"You are not authorized to access this page."}])
    expect(agent.count).to eq(0)
  end

  it "post callbacks failed" do
    params = { "deposit" => { "id" => uuid,
                              "state" => "failed",
                              "message_type" => agent.source_id,
                              "message_action" => "failed",
                              "message_size" =>  2,
                              "source_token" => agent.uuid,
                              "timestamp" => "2016-01-09T09:15:18Z" } }
    post '/api/callbacks', params.to_json, headers

    response = JSON.parse(last_response.body)
    expect(response['errors']).to eq([{"status"=>400, "title"=>"Processing of deposit #{uuid} failed"}])
    expect(agent.count).to eq(0)
  end

  it "post callbacks other state" do
    params = { "deposit" => { "id" => uuid,
                              "state" => "working",
                              "message_type" => agent.source_id,
                              "message_action" => "failed",
                              "message_size" => 12,
                              "source_token" => agent.uuid,
                              "timestamp" => "2016-01-09T09:15:18Z" } }
    post '/api/callbacks', params.to_json, headers

    response = JSON.parse(last_response.body)
    expect(response['errors']).to eq([{"status"=>422, "title"=>"Request must contain state \"done\" or \"failed\""}])
    expect(agent.count).to eq(0)
  end
end
