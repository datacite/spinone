class RelationTypeSerializer < ActiveModel::Serializer
  cache key: 'relation_type'
  attributes :title, :updated

  def updated
    object.updated_at
  end
end
