require 'spec_helper'

describe "agents", type: :feature, js: true do
  it 'is user' do
    visit '/status'
    expect(page).to have_css ".panel"
    expect(page).to have_css ".panel-body", text: "Status information is only available for administrators."
  end

  it 'is admin' do
    sign_in
    visit '/status'
    expect(page).to have_css ".panel-heading", text: "Jobs"
  end
end
