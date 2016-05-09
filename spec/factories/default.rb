FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "Josiah Carberry{n}" }
    sequence(:api_key) { |n| "q9pWP8QxzkR24Mvs9BEy#{n}" }
    provider "orcid"
    role "user"
    sequence(:uid) { |n| "0000-0002-1825-000#{n}" }

    factory :admin_user do
      role "admin"
      api_key "12345"
    end

    factory :valid_user do
      uid '0000-0003-1419-2405'
      authentication_token ENV['ORCID_AUTHENTICATION_TOKEN']
    end

    initialize_with { User.where(uid: uid).first_or_initialize }
  end

  factory :status do
    current_version "1.0-beta"
  end

  factory :datacite_related, aliases: [:agent], class: DataciteRelated do
    type "DataciteRelated"
    name "datacite_related"
    title "DataCite (RelatedIdentifier"
    state_event "activate"
    count 0

    initialize_with { DataciteRelated.where(name: name).first_or_initialize }
  end

  factory :datacite_orcid, class: DataciteOrcid do
    type "DataciteOrcid"
    name "datacite_orcid"
    title "Datacite ORCID"
    state_event "activate"
    count 0

    initialize_with { DataciteOrcid.where(name: name).first_or_initialize }
  end

  factory :datacite_github, class: DataciteGithub do
    type "DataciteGithub"
    name "datacite_github"
    title "Datacite Github"
    state_event "activate"
    count 0

    initialize_with { DataciteGithub.where(name: name).first_or_initialize }
  end

  factory :orcid_update, class: OrcidUpdate do
    type "OrcidUpdate"
    name "orcid_update"
    title "ORCID (Auto-Update)"
    state_event "activate"
    count 0

    initialize_with { OrcidUpdate.where(name: name).first_or_initialize }
  end
end
