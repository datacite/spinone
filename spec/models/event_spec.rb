require 'rails_helper'

describe Event, type: :model, vcr: true do
  it "events" do
    events = Event.where(rows: 50)
    expect(events.length).to eq(50)
    event = events.first
    expect(event.subj_id).to eq("http://doi.org/10.5517/CCSMT39")
  end

  it "events with q" do
    events = Event.where(q: "fd49e100-33a6-4dd2-98cf-143d94093958")
    expect(events.length).to eq(1)
    event = events.first
    expect(event.subj_id).to eq("http://doi.org/10.5517/CCSMT39")
  end

  it "event" do
    event = Event.where(id: "fd49e100-33a6-4dd2-98cf-143d94093958")
    expect(event.subj_id).to eq("http://doi.org/10.5517/CCSMT39")
  end
end
