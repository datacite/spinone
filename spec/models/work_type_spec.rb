require 'rails_helper'

describe WorkType, type: :model, vcr: true do
  it "work types" do
    work_types = WorkType.all[:data]
    expect(work_types.length).to eq(36)
    work_type = work_types.first
    expect(work_type.title).to eq("Article")
  end

  it "work type" do
    work_type = WorkType.where(id: "dataset")[:data]
    expect(work_type.title).to eq("Dataset")
  end
end
