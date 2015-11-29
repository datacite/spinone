require 'spec_helper'

describe Orcid, type: :model, vcr: true do
  before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8, 10, 0)) }

  context "status" do
    it "scheduled_at" do
      subject.scheduled_at = (Time.now + 1.day).iso8601
      expect(subject.scheduled_at).to eq("2015-04-09T18:40:00+00:00")
    end

    it "count" do
      subject.count = 10
      expect(subject.count).to eq(10)
    end
  end
end
