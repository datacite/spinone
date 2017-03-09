class PrefixSerializer < ActiveModel::Serializer
  cache key: 'prefix'
  attributes :registration_agency, :updated

  def updated
    object.updated_at
  end
end
