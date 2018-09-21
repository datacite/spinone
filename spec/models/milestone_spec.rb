require 'rails_helper'

describe Milestone, type: :model, vcr: true do
  it "milestones" do
    milestones = Milestone.all[:data]
    expect(milestones.length).to eq(8)
    milestone = milestones.first
    expect(milestone.title).to eq("Public API to manage clients and prefixes")
  end

  it "milestone" do
    milestone = Milestone.where(id: "10")[:data]
    expect(milestone.title).to eq("Develop new DOI Fabrica service")
  end
end
