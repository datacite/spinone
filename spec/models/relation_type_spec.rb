require 'rails_helper'

describe RelationType, type: :model, vcr: true do
  it "relation types" do
    relation_types = RelationType.all
    expect(relation_types.length).to eq(25)
    relation_type = relation_types.first
    expect(relation_type.title).to eq("Is cited by")
  end

  it "relation type" do
    relation_type = RelationType.find("IsCitedBy")
    expect(relation_type.title).to eq("Is cited by")
  end
end