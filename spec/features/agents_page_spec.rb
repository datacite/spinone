require 'rails_helper'

describe "agents", type: :feature, js: true do
  it 'lists all agents' do
    visit '/agents'
    expect(page).to have_css ".panel", count: 4
    expect(page).not_to have_css ".panel-body", visible: true
  end

  it 'expands' do
    visit '/agents'
    click_link 'link_orcid'
    expect(page).to have_css ".panel-body", visible: true
  end
end
