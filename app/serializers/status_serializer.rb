class StatusSerializer < ActiveModel::Serializer
  cache key: 'status'
  attributes :datacite_orcid_count, :datacite_github_count, :datacite_related_count, :orcid_update_count, :db_size, :version, :timestamp

  def id
    object.uuid
  end
end
