class RelationTypeSerializer < ActiveModel::Serializer
  cache key: 'relation_type'
  attributes :title
end
