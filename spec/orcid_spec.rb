require 'spec_helper'

describe Orcid, type: :model, vcr: true do
  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8))
    subject.count = 0
  end

  let(:fixture_path) { "#{Sinatra::Application.root}/spec/fixtures/" }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://search.datacite.org/api?q=nameIdentifier%3AORCID%5C%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://search.datacite.org/api?q=nameIdentifier%3AORCID%5C%3A*&start=0&rows=0&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://search.datacite.org/api?q=nameIdentifier%3AORCID%5C%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-05T00%3A00%3A00Z+TO+2015-04-05T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 250)).to eq("http://search.datacite.org/api?q=nameIdentifier%3AORCID%5C%3A*&start=250&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://search.datacite.org/api?q=nameIdentifier%3AORCID%5C%3A*&start=0&rows=250&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(55)
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
      expect(response).to eq(55)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.get_data(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response["data"]["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.get_data
      expect(response["data"]["response"]["numFound"]).to eq(55)
      doc = response["data"]["response"]["docs"].first
      expect(doc["doi"]).to eq("10.6084/M9.FIGSHARE.1226424")
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
      body = File.read(fixture_path + 'orcid_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data("data" => result)).to eq([])
    end

    it "should report if there are invalid works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'orcid_invalid.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(61)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'orcid.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(56)
      expect(response.first[:prefix]).to eq("10.6084")
      expect(response.first[:message_type]).to eq("contribution")
      expect(response.first[:relation]).to eq("subj_id"=>"http://orcid.org/0000-0001-8478-7549",
                                              "obj_id"=>"http://doi.org/10.6084/M9.FIGSHARE.1226424",
                                              "source_id"=>"datacite_orcid",
                                              "publisher_id"=>"CDL.DIGSCI",
                                              "registration_agency_id"=>"datacite",
                                              "occurred_at"=>"2015-04-08T10:13:29Z")

      expect(response.first[:obj]).to eq("pid"=>"http://doi.org/10.6084/M9.FIGSHARE.1226424",
                                         "DOI"=>"10.6084/M9.FIGSHARE.1226424",
                                         "author"=>[{"family"=>"Cotta", "given"=>"Carlos", "ORCID"=>"http://orcid.org/0000-0001-8478-7549"}, {"family"=>"Nogueras", "given"=>"Rafael"}],
                                         "title"=>"Color mememaps of self-balancing strategies",
                                         "container-title"=>"Figshare",
                                         "published"=>"2015",
                                         "issued"=>"2015-04-08T10:13:29Z",
                                         "publisher_id"=>"CDL.DIGSCI",
                                         "registration_agency_id"=>"datacite",
                                         "tracked"=>true,
                                         "type"=>"graphic")
    end
  end

  context "push_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      result = []
      expect(subject.push_data(result)).to be_empty
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'orcid.json')
      result = JSON.parse(body)
      result = subject.parse_data("data" => result)

      response = subject.push_data(result)
      expect(response.length).to eq(56)
      deposit = response.first
      expect(deposit).to eq("data"=>{"meta"=>{"status"=>"accepted",
                                              "message-type"=>"deposit",
                                              "message-version"=>"v7"},
                                     "deposit"=>{"id"=>"a016bc07-5c4b-4d94-ae37-9b8be741e752",
                                                 "state"=>"waiting",
                                                 "message_type"=>"contribution",
                                                 "message_action"=>"create",
                                                 "source_token"=>"1c1de794-97bd-477b-a686-0a6b0d309bb4",
                                                 "callback"=>"http://10.2.2.14/api/agents",
                                                 "prefix"=>"10.6084",
                                                 "subj_id"=>"http://orcid.org/0000-0001-8478-7549",
                                                 "obj_id"=>"http://doi.org/10.6084/M9.FIGSHARE.1226424",
                                                 "relation_type_id"=>"references",
                                                 "source_id"=>"datacite_orcid",
                                                 "publisher_id"=>"CDL.DIGSCI",
                                                 "total"=>1,
                                                 "occurred_at"=>"2016-04-28T08:26:47Z",
                                                 "timestamp"=>"2016-04-28T08:26:47Z",
                                                 "subj"=>{},
                                                 "obj"=>{"pid"=>"http://doi.org/10.6084/M9.FIGSHARE.1226424",
                                                         "author"=>[{"given"=>"Carlos", "family"=>"Cotta", "ORCID"=>"http://orcid.org/0000-0001-8478-7549"}, {"given"=>"Rafael", "family"=>"Nogueras"}],
                                                         "title"=>"Color mememaps of self-balancing strategies",
                                                         "container-title"=>"Figshare",
                                                         "issued"=>"2015-04-08T10:13:29Z",
                                                         "published"=>"2015",
                                                         "DOI"=>"10.6084/M9.FIGSHARE.1226424",
                                                         "registration_agency"=>"datacite",
                                                         "publisher_id"=>"CDL.DIGSCI",
                                                         "type"=>"graphic",
                                                         "tracked"=>true}}})
    end
  end
end
