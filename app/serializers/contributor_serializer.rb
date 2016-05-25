class ContributorSerializer < ActiveModel::Serializer
  cache key: 'contributor'
  attributes :given, :family, :literal, :orcid, :github, :updated

  def updated
    object.updated_at
  end
end
