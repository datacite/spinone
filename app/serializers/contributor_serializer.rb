class ContributorSerializer < ActiveModel::Serializer
  cache key: 'contributor'
  attributes :given, :family, :updated

  def updated
    object.updated_at
  end
end
