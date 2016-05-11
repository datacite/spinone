require 'rails_helper'

describe Work, type: :model, vcr: true do
  it "works" do
    works = Work.where(rows: 50)
    expect(works[:data].length).to eq(50)
    work = works[:data].first
    expect(work.title).to eq("LSSVM-Partial Differential Equations- Matlab Demo")
  end

  it "works with q" do
    works = Work.where(q: "cancer")
    expect(works[:data].length).to eq(25)
    work = works[:data].first
    expect(work.title).to eq("Sequential cancer immunotherapy: targeted activity of dimeric TNF and IL-8")
  end

  it "works with q sort by minted" do
    works = Work.where(q: "cancer", sort: "minted")
    expect(works[:data].length).to eq(25)
    work = works[:data].first
    expect(work.title).to eq("Sequential cancer immunotherapy: targeted activity of dimeric TNF and IL-8")
  end

  # it "works with registration_agency_id" do
  #   works = Work.where(registration_agency_id: "datacite")
  #   expect(works.length).to eq(1)
  #   work = works.first
  #   expect(work.title).to eq("Public Library of Science (PLoS)")
  # end

  it "work" do
    work = Work.where(id: "10.3886/ICPSR36357.V1")
    expect(work.title).to eq("027.7 - Zeitschrift für Bibliothekskultur")
  end
end
