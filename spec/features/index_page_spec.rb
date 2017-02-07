require 'rails_helper'

describe "index", type: :feature, js: true, vcr: true do
  it 'show index page' do
    visit '/'
    expect(page).to have_css ".content h2", text: "Version History"
  end

  it 'show link to support menu' do
    sign_in
    visit '/'
    expect(page).to have_css ".dropdown-toggle", text: "Support"
  end
end
