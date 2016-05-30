class RelationTypeSerializer < ActiveModel::Serializer
  cache key: 'relation_type'
  attributes :title, :inverse_title, :updated

  def updated
    object.updated_at
  end
end
