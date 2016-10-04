require 'rails_helper'

describe Group, type: :model, vcr: true do
  it "groups" do
    groups = Group.all[:data]
    expect(groups.length).to eq(13)
    group = groups.first
    expect(group.title).to eq("Cited")
  end

  it "group" do
    group = Group.where(id: "relations")[:data]
    expect(group.title).to eq("Relations")
  end
end
