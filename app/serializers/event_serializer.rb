class EventSerializer < ActiveModel::Serializer
  cache key: 'event'
  attributes :state, :message_type, :message_action, :source_token, :prefix, :subj_id, :obj_id, :subj, :obj, :source_id, :relation_type_id, :registration_agency_id, :total, :occurred, :updated

  def occured
    object.updated_at
  end

  def updated
    object.updated_at
  end
end
