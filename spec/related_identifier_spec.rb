require 'spec_helper'

describe RelatedIdentifier, type: :model, vcr: true do
  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8))
    subject.count = 0
  end

  let(:fixture_path) { "#{Sinatra::Application.root}/spec/fixtures/" }

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
      expect(subject.get_total).to eq(1181)
    end

    it "with no works" do
      expect(subject.get_total(from_date: "2009-04-07", until_date: "2009-04-08")).to eq(0)
    end
  end

  context "queue_jobs" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.queue_jobs(all: true, from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.queue_jobs(all: true)
      expect(response).to eq(1181)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.get_data(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response["data"]["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.get_data
      expect(response["data"]["response"]["numFound"]).to eq(1181)
      doc = response["data"]["response"]["docs"].first
      expect(doc["doi"]).to eq("10.5061/DRYAD.56M2G/1")
    end

    it "should catch errors with the Datacite Metadata Search API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0)).to_return(:status => [408])
      response = subject.get_data(rows: 0)
      expect(response).to eq("errors" => [{"status"=>408, "title"=>"Request timeout"}])
      expect(stub).to have_been_requested
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'related_identifier_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data("data" => result)).to eq([])
    end

    it "should report if there are invalid works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'related_identifier_invalid.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(1984)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'related_identifier.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(208)
      expect(response.first[:prefix]).to eq("10.5061")
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.5061/DRYAD.56M2G/1",
                                              "obj_id"=>"http://doi.org/10.5061/DRYAD.56M2G",
                                              "relation_type_id"=>"is_part_of",
                                              "source_id"=>"datacite_related",
                                              "publisher_id"=>"CDL.DRYAD",
                                              "registration_agency_id"=>"datacite",
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
      expect(response[100][:relation]).to eq("subj_id"=>"http://doi.org/10.5517/CC11YW84",
                                             "obj_id"=>"http://doi.org/10.3184/174751914X14108743633272",
                                             "relation_type_id"=>"is_supplement_to",
                                             "source_id"=>"datacite_crossref",
                                             "publisher_id"=>"BL.CCDC",
                                             "registration_agency_id"=>"crossref",
                                             "occurred_at"=>"2015-03-20T09:01:53Z")
    end
  end

  context "push_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      result = []
      expect(subject.push_data(result)).to be_empty
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'related_identifier.json')
      result = JSON.parse(body)
      result = subject.parse_data("data" => result)

      response = subject.push_data(result)
      expect(response.length).to eq(208)
      deposit = response.first
      expect(deposit).to eq("data"=>{"meta"=>{"status"=>"accepted",
                                               "message-type"=>"deposit",
                                               "message-version"=>"v7"},
                                      "deposit"=>{"id"=>"e3bffcb1-fce3-401b-9bbd-055ae16421cc",
                                                  "state"=>"waiting",
                                                  "message_type"=>"relation",
                                                  "message_action"=>"create",
                                                  "source_token"=>"7385e6bf-6980-45e6-ac18-b0ee6b84a50a",
                                                  "callback"=>"http://10.2.2.14/api/agents",
                                                  "prefix"=>"10.5061",
                                                  "subj_id"=>"http://doi.org/10.5061/DRYAD.56M2G/1",
                                                  "obj_id"=>"http://doi.org/10.5061/DRYAD.56M2G",
                                                  "relation_type_id"=>"is_part_of",
                                                  "source_id"=>"datacite_related",
                                                  "publisher_id"=>"CDL.DRYAD",
                                                  "total"=>1,
                                                  "occurred_at"=>"2016-04-28T09:02:09Z",
                                                  "timestamp"=>"2016-04-28T09:02:09Z",
                                                  "subj"=>{"pid"=>"http://doi.org/10.5061/DRYAD.56M2G/1",
                                                           "author"=>[{"given"=>"Thomas", "family"=>"Bataillon"}, {"given"=>"Jinjie", "family"=>"Duan"}],
                                                           "title"=>"Zip archive VCF files",
                                                           "container-title"=>"Dryad Digital Repository",
                                                           "issued"=>"2015-04-08T13:54:45Z",
                                                           "published"=>"2015",
                                                           "DOI"=>"10.5061/DRYAD.56M2G/1",
                                                           "registration_agency"=>"datacite",
                                                           "publisher_id"=>"CDL.DRYAD",
                                                           "type"=>"dataset",
                                                           "tracked"=>true},
                                                           "obj"=>{}}})
    end
  end

  context "update_count" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      subject.update_count(0)
      expect(subject.count).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      subject.update_count(12)
      expect(subject.count).to eq(12)
    end
  end
end
