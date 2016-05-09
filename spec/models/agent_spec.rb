require 'rails_helper'

describe Agent, :type => :model, vcr: true do
  include ActiveJob::TestHelper

  it { is_expected.to belong_to(:group) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_numericality_of(:timeout).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { is_expected.to validate_numericality_of(:max_failed_queries).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { is_expected.to validate_numericality_of(:rate_limiting).is_greater_than(0).only_integer.with_message("must be greater than 0") }

  describe "wait_time" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    subject { FactoryGirl.create(:agent) }

    it "no delay" do
      expect(subject.wait_time.to_i).to eq(1)
    end

    it "low rate-limiting" do
      subject = FactoryGirl.create(:agent_with_api_responses)
      subject.rate_limiting = 10
      expect(subject.wait_time.to_i).to eq(3599)
    end

    it "over rate-limiting" do
      subject = FactoryGirl.create(:agent_with_api_responses)
      subject.rate_limiting = 4
      expect(subject.wait_time.to_i).to eq(3599)
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
