require 'rails_helper'

describe DataciteRelated, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:datacite_related) }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://search.datacite.org/api?q=relatedIdentifier%3ADOI%5C%3A*&start=0&rows=200&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3ADOI%5C%3A*&start=0&rows=0&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://search.datacite.org/api?q=relatedIdentifier%3ADOI%5C%3A*&start=0&rows=200&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-05T00%3A00%3A00Z+TO+2015-04-05T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 250)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3ADOI%5C%3A*&start=250&rows=200&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3ADOI%5C%3A*&start=0&rows=250&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(714)
    end

    it "with no works" do
      expect(subject.get_total(from_date: "2009-04-07", until_date: "2009-04-08")).to eq(0)
    end
  end

  context "queue_jobs" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.queue_jobs(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.queue_jobs
      expect(response).to eq(714)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.get_data(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response["data"]["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.get_data
      expect(response["data"]["response"]["numFound"]).to eq(714)
      doc = response["data"]["response"]["docs"].first
      expect(doc["doi"]).to eq("10.5061/DRYAD.MM5M1/1")
    end

    it "should catch errors with the Datacite Metadata Search API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, source_id: subject.source_id)).to_return(:status => [408])
      response = subject.get_data(rows: 0, source_id: subject.source_id)
      expect(response).to eq("errors"=>[{"status"=>408, "title"=>"Request timeout"}])
      expect(stub).to have_been_requested
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'datacite_related_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data("data" => result)).to eq([])
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'datacite_related.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(208)
      expect(response.first[:prefix]).to eq("10.5061")
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.5061/DRYAD.56M2G/1",
                                              "obj_id"=>"http://doi.org/10.5061/DRYAD.56M2G",
                                              "relation_type_id"=>"is_part_of",
                                              "source_id"=>"datacite_related",
                                              "publisher_id"=>"CDL.DRYAD",
                                              "registration_agency_id" => "datacite",
                                              "occurred_at"=>"2015-04-08T13:54:45Z")

      expect(response.first[:subj]).to eq("pid"=>"http://doi.org/10.5061/DRYAD.56M2G/1",
                                          "DOI"=>"10.5061/DRYAD.56M2G/1",
                                          "author"=>[{"family"=>"Bataillon", "given"=>"Thomas"}, {"family"=>"Duan", "given"=>"Jinjie"}],
                                          "title"=>"Zip archive VCF files",
                                          "container-title"=>"Dryad Digital Repository",
                                          "published"=>"2015",
                                          "issued"=>"2015-04-08T13:54:45Z",
                                          "publisher_id"=>"CDL.DRYAD",
                                          "registration_agency_id"=>"datacite",
                                          "tracked"=>true,
                                          "type"=>"dataset")

      expect(response[2][:prefix]).to eq("10.5061")
      expect(response[2][:relation]).to eq("subj_id"=>"http://doi.org/10.5061/DRYAD.HT0HS",
                                           "obj_id"=>"http://doi.org/10.1186/S12864-015-1469-5",
                                           "relation_type_id"=>"is_referenced_by",
                                           "source_id"=>"datacite_crossref",
                                           "publisher_id"=>"CDL.DRYAD",
                                           "registration_agency_id" => "crossref",
                                           "occurred_at"=>"2015-04-08T14:37:53Z")
    end

    it "should catch timeout errors with the Datacite Metadata Search API" do
      result = { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/", status: 408 }
      response = subject.parse_data(result)
      expect(response).to eq([result])
    end
  end

  context "push_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      result = []
      expect(subject.push_data(result)).to be_empty
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'datacite_related.json')
      result = JSON.parse(body)
      result = subject.parse_data("data" => result)

      response = subject.push_data(result)
      expect(response.length).to eq(208)
      deposit = response.first
      expect(deposit["data"]["meta"]).to eq("status"=>"accepted",
                                            "message-type"=>"deposit",
                                            "message-version"=>"v7")
      expect(deposit["data"]["deposit"]["message_type"]).to eq("relation")
      expect(deposit["data"]["deposit"]["subj"]).to eq("pid"=>"http://doi.org/10.5061/DRYAD.56M2G/1",
                                                       "author"=>[{"given"=>"Thomas", "family"=>"Bataillon"}, {"given"=>"Jinjie", "family"=>"Duan"}],
                                                       "title"=>"Zip archive VCF files",
                                                       "container-title"=>"Dryad Digital Repository",
                                                       "issued"=>"2015-04-08T13:54:45Z",
                                                       "published"=>"2015",
                                                       "DOI"=>"10.5061/DRYAD.56M2G/1",
                                                       "registration_agency_id"=>"datacite",
                                                       "publisher_id"=>"CDL.DRYAD",
                                                       "type"=>"dataset",
                                                       "tracked"=>true)
    end
  end
end
