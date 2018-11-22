require 'rails_helper'

describe Member, type: :model, vcr: true do
  it "members" do
    members = Member.all[:data]
    expect(members.length).to eq(25)
    member = members.first
    expect(member.title).to eq("ALBA Synchrotron Light Source")
  end

  it "member" do
    member = Member.where(id: "ands")[:data]
    expect(member.title).to eq("Australian National Data Service")
  end
end
