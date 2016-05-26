class ContributionSerializer < ActiveModel::Serializer
  cache key: 'contribution'
  attributes :doi, :credit_name, :orcid, :author, :title, :container_title, :source_id, :contributor_role_id, :type, :published, :issued, :updated

  def updated
    object.updated_at
  end
end
