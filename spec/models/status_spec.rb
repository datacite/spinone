require 'rails_helper'

describe Status, type: :model, vcr: true do
  subject { FactoryGirl.create(:status) }

  it "datacite_github_count" do
    datacite_github = FactoryGirl.create(:datacite_github)
    datacite_github.update_count(2)
    expect(subject.datacite_github_count).to eq(2)
  end

  it "datacite_orcid_count" do
    datacite_orcid = FactoryGirl.create(:datacite_orcid)
    datacite_orcid.update_count(1)
    expect(subject.datacite_orcid_count).to eq(1)
  end

  it "datacite_related_count" do
    datacite_related = FactoryGirl.create(:datacite_related)
    datacite_related.update_count(3)
    expect(subject.datacite_related_count).to eq(3)
  end

  it "orcid_update_count" do
    orcid_update = FactoryGirl.create(:orcid_update)
    orcid_update.update_count(4)
    expect(subject.orcid_update_count).to eq(4)
  end

  it "current_version" do
    expect(subject.current_version).to eq("1.0-beta")
  end

  context "services" do
    it "redis" do
      expect(subject.redis).to eq("OK")
    end

    it "sidekiq" do
      expect(subject.sidekiq).to eq("OK")
    end

    it "services_ok?" do
      expect(subject.services_ok?).to be true
    end
  end
end
