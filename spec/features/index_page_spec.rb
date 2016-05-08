require 'rails_helper'

describe "index", type: :feature, js: true, vcr: true do
  it 'show index page' do
    visit '/'
    expect(page).to have_css ".panel-body", text: "The DataCite API sends newly indexed metadata from the DataCite Metadata Store to other DataCite services. Please contact DataCite staff for more information."
  end

  it 'show link to agents' do
    sign_in
    visit '/'
    expect(page).to have_css ".navbar-nav li a", text: "Agents"
  end

  it 'not authorized' do
    visit '/'
    expect(page).not_to have_css ".navbar-nav li a", text: "Agents"
  end

  it 'invalid_credentials' do
    sign_in(credentials: "invalid")
    visit '/'
    expect(page).not_to have_css ".navbar-nav li a", text: "Agents"
  end

  it 'role user' do
    sign_in(role: "user")
    visit '/'
    expect(page).not_to have_css ".navbar-nav li a", text: "Agents"
  end
end
