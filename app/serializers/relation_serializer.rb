class RelationSerializer < ActiveModel::Serializer
  cache key: 'relation'
  attributes :subj_id, :obj_id, :doi, :author, :title, :container_title, :source_id, :relation_type_id, :publisher_id, :registration_agency_id, :work_type_id, :total, :published, :issued, :updated

  belongs_to :publisher, serializer: PublisherSerializer
  belongs_to :source, serializer: SourceSerializer
  belongs_to :relation_type, serializer: RelationTypeSerializer

  def updated
    object.updated_at
  end
end
