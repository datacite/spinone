require 'rails_helper'

describe Status, type: :model, vcr: true do
  subject { FactoryGirl.create(:status) }

  it "current_version" do
    expect(subject.current_version).to eq("2.0")
  end
end
