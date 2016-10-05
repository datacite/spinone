require 'rails_helper'

describe Relation, type: :model, vcr: true do
  it "relations" do
    result = Relation.where(rows: 50)
    relations = result[:data]
    relation = relations.first
    expect(relation.title).to eq("Early ovariectomy reveals the germline encoding of the “natural” mammalian anti-A-reactive IgM reflecting developmental malignancy.")
  end

  it "relations with filter by source" do
    result = Relation.where("source-id" => "datacite-crossref")
    relations = result[:data]
    relation = relations.first
    expect(relation.title).to eq("On the Stabilizing Influence of Silt On Sand Beds")
    expect(relation.source.title).to eq("DataCite (Crossref)")
  end

  it "relations with filter by relation type" do
    result = Relation.where("relation-type-id" => "references")
    relations = result[:data]
    relation = relations.first
    expect(relation.title).to eq("Trace element concent of Stagamite MF-3 from Schafsloch Cave")
    expect(relation.relation_type.title).to eq("References")
  end
end
