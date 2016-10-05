class ContributionSerializer < ActiveModel::Serializer
  cache key: 'contribution'
  attributes :subj_id, :obj_id, :credit_name, :orcid, :github, :author, :doi, :url, :title, :container_title, :contributor_role_id, :work_type, :published, :issued, :updated

  belongs_to :publisher, serializer: PublisherSerializer
  belongs_to :source, serializer: SourceSerializer

  def updated
    object.updated_at
  end
end
