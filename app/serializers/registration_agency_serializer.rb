class RegistrationAgencySerializer < ActiveModel::Serializer
  cache key: 'registration_agency'
  attributes :title, :updated

  def updated
    object.updated_at
  end
end
