require 'rails_helper'

describe "index", type: :feature, js: true, vcr: true do
  it 'show index page' do
    visit '/'
    expect(page).to have_css ".content h2", text: "Version History"
  end

  it 'show link to admin menu' do
    sign_in
    visit '/'
    expect(page).to have_css ".dropdown-toggle", text: "Admin"
  end

  it 'not authorized' do
    visit '/'
    expect(page).not_to have_css ".dropdown-toggle", text: "Agents"
  end

  it 'invalid_credentials' do
    sign_in(credentials: "invalid")
    visit '/'
    expect(page).not_to have_css ".dropdown-toggle", text: "Agents"
  end

  it 'role user' do
    sign_in(role: "user")
    visit '/'
    expect(page).not_to have_css ".dropdown-toggle", text: "Agents"
  end
end
