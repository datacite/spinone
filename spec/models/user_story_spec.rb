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
    user_story = UserStory.where(id: "59")[:data]
    expect(user_story.title).to eq("Automatic DOI suffix generation")
    expect(user_story.description).to start_with("<p>As a data center, I want the option")
    expect(user_story.milestone).to eq("Develop new DOI Fabrica Service")
    expect(user_story.projects).to eq(["fabrica"])
    expect(user_story.stakeholders).to eq(["data center"])
    expect(user_story.state).to eq("inbox")
  end
end