require 'rails_helper'

describe Work, type: :model, vcr: true do
  context "get_query_url" do
    it "default" do
      expect(Work.get_query_url).to eq("https://search.test.datacite.org/api?q=*%3A*&start=0&rows=25&fl=doi%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&fq=has_metadata%3Atrue+AND+is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=minted+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&wt=json")
    end

    it "with rows" do
      expect(Work.get_query_url(page: { size: 50 })).to eq("https://search.test.datacite.org/api?q=*%3A*&start=0&rows=50&fl=doi%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&fq=has_metadata%3Atrue+AND+is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=minted+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&wt=json")
    end

    it "with q" do
      expect(Work.get_query_url(query: "cancer")).to eq("https://search.test.datacite.org/api?q=cancer&start=0&rows=25&fl=doi%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&fq=has_metadata%3Atrue+AND+is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=score+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&wt=json")
    end

    it "with q sort by minted" do
      expect(Work.get_query_url(query: "cancer", sort: "minted")).to eq("https://search.test.datacite.org/api?q=cancer&start=0&rows=25&fl=doi%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&fq=has_metadata%3Atrue+AND+is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=score+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&wt=json")
    end

    it "with id" do
      expect(Work.get_query_url(id: "10.5061/DRYAD.Q447C")).to eq("https://search.test.datacite.org/api?q=10.5061%2FDRYAD.Q447C&qf=doi&defType=edismax&wt=json")
    end

    it "with work-id" do
      expect(Work.get_query_url("work-id" => "10.5061/DRYAD.Q447C")).to eq("https://search.test.datacite.org/api?q=10.5061%2FDRYAD.Q447C&qf=doi&fl=doi%2CrelatedIdentifier&defType=edismax&wt=json")
    end

    it "with ids" do
      expect(Work.get_query_url(ids: "10.5061/DRYAD.Q447C/1,10.5061/DRYAD.Q447C/2,10.5061/DRYAD.Q447C/3")).to eq("https://search.test.datacite.org/api?q=+10.5061%2FDRYAD.Q447C%2F1+10.5061%2FDRYAD.Q447C%2F2+10.5061%2FDRYAD.Q447C%2F3&start=0&rows=25&fl=doi%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&qf=doi&fq=has_metadata%3Atrue+AND+is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=minted+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&mm=1&wt=json")
    end

    it "with date created range" do
      expect(Work.get_query_url("until-created-date" => "2015")).to eq("https://search.test.datacite.org/api?q=*%3A*&start=0&rows=25&fl=doi%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&fq=has_metadata%3Atrue+AND+is_active%3Atrue+AND+minted%3A%5B*+TO+2015-12-31T23%3A59%3A59Z%5D&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=minted+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&wt=json")
    end
  end

  context "normalize license" do
    it "cc0" do
      rights_uri = ["http://creativecommons.org/publicdomain/zero/1.0/"]
      expect(subject.normalize_license(rights_uri)).to eq("https://creativecommons.org/publicdomain/zero/1.0/")
    end

    it "cc-by" do
      rights_uri = ["https://creativecommons.org/licenses/by/4.0/"]
      expect(subject.normalize_license(rights_uri)).to eq("https://creativecommons.org/licenses/by/4.0/")
    end

    it "cc-by no trailing slash" do
      rights_uri = ["https://creativecommons.org/licenses/by/4.0"]
      expect(subject.normalize_license(rights_uri)).to eq("https://creativecommons.org/licenses/by/4.0/")
    end

    it "by-nc-nd" do
      rights_uri = ["https://creativecommons.org/licenses/by-nc-nd/4.0/"]
      expect(subject.normalize_license(rights_uri)).to eq("https://creativecommons.org/licenses/by-nc-nd/4.0/")
    end
  end

  it "works" do
    works = Work.where(page: { size: 60 })
    expect(works[:data].length).to eq(60)
    work = works[:data].last
    expect(work.title).to eq("Dataset A from workspace-1519831024653")
    expect(work.container_title).to eq("herausgeber-1519831686455")
    expect(work.author).to eq([{"literal"=>"Ersteller-1519831685128"}])
    meta = works[:meta]
    expect(meta["resource-types"]).not_to be_empty
    expect(meta["years"]).not_to be_empty
    expect(meta).not_to be_empty
  end

  it "works with query" do
    works = Work.where(query: "cancer")
    expect(works[:data].length).to eq(8)
    work = works[:data].first
    expect(work.title).to eq("Genome-Wide Meta-Analyses of Breast, Ovarian, and Prostate Cancer Association Studies Identify Multiple New Susceptibility Loci Shared by at Least Two Cancer Types.")
    expect(work.author.length).to eq(230)
    expect(work.author.first).to eq("given"=>"Siddhartha P", "family"=>"Kar")
    expect(work.resource_type.title).to eq("Text")
  end

  it "works with query sort by minted" do
    works = Work.where(query: "cancer", sort: "minted")
    expect(works[:data].length).to eq(8)
    work = works[:data].first
    expect(work.title).to eq("Genome-Wide Meta-Analyses of Breast, Ovarian, and Prostate Cancer Association Studies Identify Multiple New Susceptibility Loci Shared by at Least Two Cancer Types.")
    expect(work.resource_type.title).to eq("Text")
  end

  it "works with resource-type-id" do
    works = Work.where("resource-type-id" => "dataset")
    expect(works[:data].length).to eq(25)
    work = works[:data].first
    expect(work.title).to eq( "One, two, Freddy's coming for you")
    expect(work.author).to eq([{"given"=>"Vorname", "family"=>"Name"}])
    expect(work.resource_type.title).to eq("Dataset")
  end

  it "works with resource-type-id and data-center-id" do
    works = Work.where("resource-type-id" => "dataset", "data-center-id" => "bl.mendeley")
    expect(works[:data].length).to eq(25)
    work = works[:data].first
    expect(work.title).to eq("Embargo changer")
    expect(work.resource_type.title).to eq("Dataset")
  end

  it "work" do
    work = Work.where(id: "10.4124/9f7xnnys8c.5")[:data]
    expect(work.title).to eq("DAT-3025 Maintain file ordering for published datasets - 4")
    expect(work.author).to eq([{"given"=>"Mahesh", "family"=>"Natra"}])
    expect(work.resource_type.title).to eq("Dataset")
    expect(work.data_center.name).to eq("Mendeley Data")
  end
end
