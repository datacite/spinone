require 'spec_helper'

describe Status, type: :model, vcr: true do
  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8))
    subject.reset
    Orcid.new.count = 10
    RelatedIdentifier.new.count = 100
  end

  context "status" do
    it "count" do
      subject.write
      status = subject.read.first
      expect(status['timestamp']).to eq("2015-04-08T00:00:00+00:00")
      expect(status['orcid']).to eq(10)
      expect(status['version']).to eq(App::VERSION)
    end

    it "counts" do
      subject.write
      status = subject.counts.first
      expect(status['type']).to eq("status")
      expect(status['attributes']).to eq("orcid"=>10, "related_identifier"=>100, "version"=>App::VERSION, "timestamp"=>"2015-04-08T00:00:00+00:00")
    end
  end
end
