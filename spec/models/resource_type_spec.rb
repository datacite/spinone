require 'rails_helper'

describe ResourceType, type: :model, vcr: true do
  it "resource types" do
    resource_types = ResourceType.all[:data]
    expect(resource_types.length).to eq(14)
    resource_type = resource_types.first
    expect(resource_type.title).to eq("Audiovisual")
  end

  it "resource type" do
    resource_type = ResourceType.where(id: "dataset")[:data]
    expect(resource_type.title).to eq("Dataset")
  end
end
