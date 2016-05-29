class RelationSerializer < ActiveModel::Serializer
  cache key: 'relation'
  attributes :subj_id, :obj_id, :doi, :author, :title, :container_title, :source_id, :publisher_id, :registration_agency_id, :relation_type_id, :type, :total, :published, :issued, :updated

  def updated
    object.updated_at
  end
end
