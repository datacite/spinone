require 'rails_helper'

describe "claims", type: :feature, js: true, vcr: true do
  it 'datacite_github' do
    visit '/dashboard'
    expect(page).to have_css ".panel"
    expect(page).to have_css ".panel-heading", text: "DataCite (GitHub)"
  end

  it 'datacite_orcid' do
    visit '/dashboard'
    expect(page).to have_css ".panel"
    expect(page).to have_css ".panel-heading", text: "DataCite (ORCID)"
  end

  it 'datacite_related' do
    visit '/dashboard'
    expect(page).to have_css ".panel"
    expect(page).to have_css ".panel-heading", text: "DataCite (RelatedIdentifier)"
  end

  it 'orcid_auto_update' do
    visit '/dashboard'
    expect(page).to have_css ".panel"
    expect(page).to have_css ".panel-heading", text: "ORCID (Auto-Update)"
  end

  it 'jobs for admin' do
    sign_in
    visit '/dashboard'
    expect(page).to have_css ".panel-heading", text: "Jobs"
  end

  it 'database for admin' do
    sign_in
    visit '/dashboard'
    expect(page).to have_css ".panel-heading", text: "Database size"
  end
end
