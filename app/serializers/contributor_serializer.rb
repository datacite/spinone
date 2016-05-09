class ContributorSerializer < ActiveModel::Serializer
  cache key: 'contributor'
  attributes :given, :family, :updated_at
end
