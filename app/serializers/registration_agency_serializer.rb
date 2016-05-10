class RegistrationAgencySerializer < ActiveModel::Serializer
  cache key: 'registration_agency'
  attributes :title, :updated_at
end
