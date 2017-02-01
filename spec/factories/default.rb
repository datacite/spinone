FactoryGirl.define do
  factory :user do
    skip_create

    sequence(:name) { |n| "Josiah Carberry{n}" }
    sequence(:api_key) { |n| "q9pWP8QxzkR24Mvs9BEy#{n}" }
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
  end

  factory :status do
    current_version "2.0"
  end

  factory :datacite_related, aliases: [:agent], class: DataciteRelated do
    type "DataciteRelated"
    name "datacite_related"
    title "DataCite (RelatedIdentifier"
    state_event "activate"
    count 0

    initialize_with { DataciteRelated.where(name: name).first_or_initialize }
  end

  factory :datacite_github, class: DataciteGithub do
    type "DataciteGithub"
    name "datacite_github"
    title "Datacite Github"
    state_event "activate"
    count 0

    initialize_with { DataciteGithub.where(name: name).first_or_initialize }
  end
end
