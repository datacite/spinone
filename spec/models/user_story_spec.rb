require 'rails_helper'

describe UserStory, type: :model, vcr: true do
  it "get_total" do
    total = UserStory.get_total
    expect(total).to eq(64)
  end

  it "user_stories" do
    user_stories = UserStory.all[:data]
    expect(user_stories.size).to eq(25)
    user_story = user_stories.first
    expect(user_story.title).to eq("Add changes in 4.0 and 4.1 schema to Solr index")
  end

  it "user_story" do
    user_story = UserStory.where(id: "10")[:data]
    expect(user_story.title).to eq("DOI Registration Reports")
    expect(user_story.description).to start_with("<p>As a member, I want to have statistics")
  end
end
