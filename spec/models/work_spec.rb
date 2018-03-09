require 'rails_helper'

describe Work, type: :model, vcr: true do
  context "get_query_url" do
    it "default" do
      expect(Work.get_query_url).to eq("https://search.test.datacite.org/api?q=*%3A*&start=0&rows=25&fl=doi%2Curl%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&fq=has_metadata%3Atrue+AND+is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=minted+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&wt=json")
    end

    it "with rows" do
      expect(Work.get_query_url(page: { size: 50 })).to eq("https://search.test.datacite.org/api?q=*%3A*&start=0&rows=50&fl=doi%2Curl%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&fq=has_metadata%3Atrue+AND+is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=minted+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&wt=json")
    end

    it "with q" do
      expect(Work.get_query_url(query: "cancer")).to eq("https://search.test.datacite.org/api?q=cancer&start=0&rows=25&fl=doi%2Curl%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&fq=has_metadata%3Atrue+AND+is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=score+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&wt=json")
    end

    it "with q sort by minted" do
      expect(Work.get_query_url(query: "cancer", sort: "minted")).to eq("https://search.test.datacite.org/api?q=cancer&start=0&rows=25&fl=doi%2Curl%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&fq=has_metadata%3Atrue+AND+is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=score+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&wt=json")
    end

    it "with id" do
      expect(Work.get_query_url(id: "10.5061/DRYAD.Q447C")).to eq("https://search.test.datacite.org/api?q=10.5061%2FDRYAD.Q447C&qf=doi&defType=edismax&wt=json")
    end

    it "with work-id" do
      expect(Work.get_query_url("work-id" => "10.5061/DRYAD.Q447C")).to eq("https://search.test.datacite.org/api?q=10.5061%2FDRYAD.Q447C&qf=doi&fl=doi%2CrelatedIdentifier&defType=edismax&wt=json")
    end

    it "with ids" do
      expect(Work.get_query_url(ids: "10.5061/DRYAD.Q447C/1,10.5061/DRYAD.Q447C/2,10.5061/DRYAD.Q447C/3")).to eq("https://search.test.datacite.org/api?q=+10.5061%2FDRYAD.Q447C%2F1+10.5061%2FDRYAD.Q447C%2F2+10.5061%2FDRYAD.Q447C%2F3&start=0&rows=25&fl=doi%2Curl%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&qf=doi&fq=has_metadata%3Atrue+AND+is_active%3Atrue&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=minted+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&mm=1&wt=json")
    end

    it "with date created range" do
      expect(Work.get_query_url("until-created-date" => "2015")).to eq("https://search.test.datacite.org/api?q=*%3A*&start=0&rows=25&fl=doi%2Curl%2Ctitle%2Ccreator%2Cdescription%2Cpublisher%2CpublicationYear%2CresourceType%2CresourceTypeGeneral%2CrightsURI%2Cversion%2Cdatacentre_symbol%2Callocator_symbol%2Cschema_version%2Cxml%2Cmedia%2Cminted%2Cupdated&fq=has_metadata%3Atrue+AND+is_active%3Atrue+AND+minted%3A%5B*+TO+2015-12-31T23%3A59%3A59Z%5D&facet=true&facet.field=publicationYear&facet.field=datacentre_facet&facet.field=resourceType_facet&facet.field=schema_version&facet.field=minted&facet.limit=15&facet.mincount=1&facet.range=minted&f.minted.facet.range.start=2004-01-01T00%3A00%3A00Z&f.minted.facet.range.end=2024-01-01T00%3A00%3A00Z&f.minted.facet.range.gap=%2B1YEAR&sort=minted+desc&defType=edismax&bq=updated%3A%5BNOW%2FDAY-1YEAR+TO+NOW%2FDAY%5D&wt=json")
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
end
