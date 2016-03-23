require 'spec_helper'

describe OrcidUpdate, type: :model, vcr: true do
  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8))
    subject.count = 0
  end

  let(:fixture_path) { "#{Sinatra::Application.root}/spec/fixtures/" }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://search.datacite.org/api?q=nameIdentifier%3AORCID%5C%3A*&start=0&rows=1000&fl=doi%2CnameIdentifier%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://search.datacite.org/api?q=nameIdentifier%3AORCID%5C%3A*&start=0&rows=0&fl=doi%2CnameIdentifier%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://search.datacite.org/api?q=nameIdentifier%3AORCID%5C%3A*&start=0&rows=1000&fl=doi%2CnameIdentifier%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-05T00%3A00%3A00Z+TO+2015-04-05T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 250)).to eq("http://search.datacite.org/api?q=nameIdentifier%3AORCID%5C%3A*&start=250&rows=1000&fl=doi%2CnameIdentifier%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://search.datacite.org/api?q=nameIdentifier%3AORCID%5C%3A*&start=0&rows=250&fl=doi%2CnameIdentifier%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(59)
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
      expect(response).to eq(59)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.get_data(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response["data"]["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.get_data
      expect(response["data"]["response"]["numFound"]).to eq(59)
      doc = response["data"]["response"]["docs"].first
      expect(doc["doi"]).to eq("10.5284/1030449")
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
      body = File.read(fixture_path + 'orcid_update_invalid.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(58)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'orcid_update.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(60)
      item = response.first
      expect(item).to eq("orcid"=>"0000-0003-3938-899X",
                         "doi"=>"10.5284/1030449",
                         "source_id"=>"orcid_update")
    end

    it "should report if there are works with parent returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'orcid_update.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(60)
      item = response[17]
      expect(item).to eq("orcid"=>"0000-0002-4133-2218",
                         "doi"=>"10.1594/PANGAEA.733793",
                         "source_id"=>"orcid_update")
    end
  end

  context "push_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      result = []
      expect(subject.push_data(result)).to be_empty
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'orcid_update.json')
      result = JSON.parse(body)
      result = subject.parse_data("data" => result)

      response = subject.push_data(result)
      expect(response.length).to eq(60)
      claim = response.first
      expect(claim).to eq("data"=>{"id"=>"054a6396-6611-4945-8727-3cec90f13233",
                                   "type"=>"claims",
                                   "attributes"=>{"orcid"=>"0000-0003-3938-899X",
                                                  "doi"=>"10.5284/1030449",
                                                  "source_id"=>"orcid_update",
                                                  "state"=>"ignored",
                                                  "claimed_at"=>nil}})

    end
  end
end
