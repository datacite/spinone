require 'rails_helper'

describe '/heartbeat', type: :api do
  it "get heartbeat" do
    get '/heartbeat'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("OK")
  end
end
