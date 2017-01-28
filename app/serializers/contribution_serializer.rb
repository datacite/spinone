class ContributionSerializer < ActiveModel::Serializer
  cache key: 'contribution'
  attributes :subj_id, :obj_id, :given, :family, :credit_name, :orcid, :github, :author, :doi, :url, :title, :container_title, :contributor_role_id, :source_id, :data_center_id, :work_type_id, :published, :issued, :updated

  belongs_to :publisher, serializer: DataCenterSerializer
  belongs_to :source, serializer: SourceSerializer

  def updated
    object.updated_at
  end
end
