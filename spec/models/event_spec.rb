require 'rails_helper'

describe Event, type: :model, vcr: true do
  it "events" do
    events = Event.where(rows: 50)[:data]
    expect(events.length).to eq(50)
    event = events.first
    expect(event.subj_id).to eq("ZBW.ZOEBIS")
  end

  it "events with query" do
    events = Event.where(query: "49f6eb94-f3cc-42a5-b95b-50f0e53f301c")[:data]
    expect(events.length).to eq(1)
    event = events.first
    expect(event.subj_id).to eq("ZBW.ZOEBIS")
  end

  it "event" do
    event = Event.where(id: "49f6eb94-f3cc-42a5-b95b-50f0e53f301c")[:data]
    expect(event.subj_id).to eq("ZBW.ZOEBIS")
  end
end
