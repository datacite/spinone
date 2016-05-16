class ResourceTypeSerializer < ActiveModel::Serializer
  cache key: 'resource_type'
  attributes :title
end
