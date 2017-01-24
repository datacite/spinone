class PersonSerializer < ActiveModel::Serializer
  cache key: 'person'
  attributes :given, :family, :literal, :orcid, :github, :updated

  def updated
    object.updated_at
  end
end
