require 'spec_helper'

describe Github, type: :model, vcr: true do
  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8))
    subject.count = 0
  end

  let(:fixture_path) { "#{Sinatra::Application.root}/spec/fixtures/" }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=0&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-05T00%3A00%3A00Z+TO+2015-04-05T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 250)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=250&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=250&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(19)
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
      expect(response).to eq(19)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.get_data(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response["data"]["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.get_data
      expect(response["data"]["response"]["numFound"]).to eq(19)
      doc = response["data"]["response"]["docs"].first
      expect(doc["doi"]).to eq("10.5281/ZENODO.16396")
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
      body = File.read(fixture_path + 'github_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data("data" => result)).to eq([])
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'github.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(60)
      expect(response[6][:prefix]).to eq("10.5281")
      expect(response[6][:relation]).to eq("subj_id"=>"http://doi.org/10.5281/ZENODO.16650",
                                           "obj_id"=>"https://github.com/moorepants/DynamicistToolKit/tree/v0.4.0",
                                           "relation_type_id"=>"is_supplement_to",
                                           "source_id"=>"datacite_github",
                                           "publisher_id"=>"CERN.ZENODO",
                                           "registration_agency_id"=>"github",
                                           "occurred_at"=>"2015-04-07T05:43:27Z")

      expect(response[6][:subj]).to eq("pid"=>"http://doi.org/10.5281/ZENODO.16650",
                                       "DOI"=>"10.5281/ZENODO.16650",
                                       "author"=>[{"family"=>"Moore", "given"=>"Jason K."}, {"family"=>"Dembia", "given"=>"Christopher"}],
                                       "title"=>"DynamicistToolKit: Version 0.4.0",
                                       "container-title"=>"Zenodo",
                                       "published"=>"2015",
                                       "issued"=>"2015-04-07T05:43:27Z",
                                       "publisher_id"=>"CERN.ZENODO",
                                       "registration_agency_id"=>"datacite",
                                       "tracked"=>true,
                                        "type"=>"computer_program")
    end
  end

  context "push_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      result = []
      expect(subject.push_data(result)).to be_empty
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'github.json')
      result = JSON.parse(body)
      result = subject.parse_data("data" => result)

      response = subject.push_data(result)
      expect(response.length).to eq(60)
      deposit = response.first
      expect(deposit).to eq("data"=>{"meta"=>{"status"=>"accepted", "message-type"=>"deposit", "message-version"=>"v7"}, "deposit"=>{"id"=>"e92e66da-2203-400e-aad3-ef3b4ec60525", "state"=>"waiting", "message_type"=>"relation", "message_action"=>"create", "source_token"=>"7385e6bf-6980-45e6-fg65-b0ee6b84a50a", "callback"=>"http://10.2.2.14/api/agents", "prefix"=>"10.5281", "subj_id"=>"http://doi.org/10.5281/ZENODO.16396", "obj_id"=>"http://doi.org/10.1007/S11548-015-1180-7", "relation_type_id"=>"is_supplement_to", "source_id"=>"datacite_crossref", "publisher_id"=>"CERN.ZENODO", "total"=>1, "occurred_at"=>"2016-04-28T09:39:24Z", "timestamp"=>"2016-04-28T09:39:24Z", "subj"=>{"pid"=>"http://doi.org/10.5281/ZENODO.16396", "author"=>[{"given"=>"Andrey", "family"=>"Fedorov"}, {"given"=>"Paul L", "family"=>"Nguyen"}, {"given"=>"Kemal", "family"=>"Tuncali"}, {"given"=>"Clare", "family"=>"Tempany"}], "title"=>"Annotated MRI and ultrasound volume images of the prostate", "container-title"=>"Zenodo", "issued"=>"2015-03-26T20:45:10Z", "published"=>"2015", "DOI"=>"10.5281/ZENODO.16396", "registration_agency_id"=>"datacite", "publisher_id"=>"CERN.ZENODO", "type"=>"dataset", "tracked"=>true}, "obj"=>{}}})
    end
  end
end
