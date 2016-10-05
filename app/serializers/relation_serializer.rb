class RelationSerializer < ActiveModel::Serializer
  cache key: 'relation'
  attributes :subj_id, :obj_id, :doi, :author, :title, :container_title, :publisher_id, :registration_agency_id, :work_type, :total, :published, :issued, :updated

  belongs_to :relation_type, serializer: RelationTypeSerializer
  belongs_to :source, serializer: SourceSerializer

  def updated
    object.updated_at
  end
end
