require 'rails_helper'

describe Work, type: :model, vcr: true do
  context "get_query_url" do
    it "default" do
      expect(Work.get_query_url).to eq("https://search.datacite.org/api?q=*%3A*&start=0&rows=25&fl=doi%2Ctitle%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cdatacentre_symbol%2Cxml%2Cminted%2Cupdated&fq=has_metadata%3Atrue&fq=is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.limit=10&f.resourceType_facet.facet.limit=15&facet.mincount=1&sort=minted+desc&wt=json")
    end

    it "with rows" do
      expect(Work.get_query_url(rows: 50)).to eq("https://search.datacite.org/api?q=*%3A*&start=0&rows=50&fl=doi%2Ctitle%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cdatacentre_symbol%2Cxml%2Cminted%2Cupdated&fq=has_metadata%3Atrue&fq=is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.limit=10&f.resourceType_facet.facet.limit=15&facet.mincount=1&sort=minted+desc&wt=json")
    end

    it "with q" do
      expect(Work.get_query_url(q: "cancer")).to eq("https://search.datacite.org/api?q=cancer&start=0&rows=25&fl=doi%2Ctitle%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cdatacentre_symbol%2Cxml%2Cminted%2Cupdated&fq=has_metadata%3Atrue&fq=is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.limit=10&f.resourceType_facet.facet.limit=15&facet.mincount=1&sort=score+desc&wt=json")
    end

    it "with q sort by minted" do
      expect(Work.get_query_url(q: "cancer", sort: "minted")).to eq("https://search.datacite.org/api?q=cancer&start=0&rows=25&fl=doi%2Ctitle%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cdatacentre_symbol%2Cxml%2Cminted%2Cupdated&fq=has_metadata%3Atrue&fq=is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.limit=10&f.resourceType_facet.facet.limit=15&facet.mincount=1&sort=score+desc&wt=json")
    end
  end

  it "works" do
    works = Work.where(rows: 60)
    expect(works[:data].length).to eq(75)
    work = works[:data].first
    expect(work.title).to eq("Using Google Earth to improve management of threatened limestone karst ecosystems in Peninsular Malaysia")
    included = works[:data][74]
    expect(included.title).to eq("Service")
  end

  it "works with q" do
    works = Work.where(q: "cancer")
    expect(works[:data].length).to eq(35)
    work = works[:data].first
    expect(work.title).to eq("Sequential cancer immunotherapy: targeted activity of dimeric TNF and IL-8")
    included = works[:data][34]
    expect(included.title).to eq("Sound")
  end

  it "works with q sort by minted" do
    works = Work.where(q: "cancer", sort: "minted")
    expect(works[:data].length).to eq(35)
    work = works[:data].first
    expect(work.title).to eq("Sequential cancer immunotherapy: targeted activity of dimeric TNF and IL-8")
    included = works[:data][34]
    expect(included.title).to eq("Sound")
  end

  it "works with q and resource-type-id" do
    works = Work.where(q: "cancer", "resource-type-id" => "dataset")
    expect(works[:data].length).to eq(26)
    work = works[:data].first
    expect(work.title).to eq("Women's Healthy Eating and Living (WHEL) Study")
    included = works[:data][25]
    expect(included.title).to eq("Dataset")
  end

  it "works with q and resource-type-id and publisher-id" do
    works = Work.where(q: "cancer", "resource-type-id" => "dataset", "publisher-id" => "CDL.DIGSCI")
    expect(works[:data].length).to eq(26)
    work = works[:data].first
    expect(work.title).to eq("Women's Healthy Eating and Living (WHEL) Study")
    included = works[:data][25]
    expect(included.title).to eq("Dataset")
  end

  # it "works with registration_agency_id" do
  #   works = Work.where(registration_agency_id: "datacite")
  #   expect(works.length).to eq(1)
  #   work = works.first
  #   expect(work.title).to eq("Public Library of Science (PLoS)")
  # end

  it "work" do
    work = Work.where(id: "10.3886/ICPSR36357.V1")
    work = work[:data]
    expect(work.title).to eq("Arts and Cultural Production Satellite Account")
  end
end
