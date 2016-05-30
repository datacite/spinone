class ContributionSerializer < ActiveModel::Serializer
  cache key: 'contribution'
  attributes :subj_id, :obj_id, :credit_name, :orcid, :github, :author, :doi, :url, :title, :container_title, :source_id, :contributor_role_id, :type, :published, :issued, :updated

  def updated
    object.updated_at
  end
end
