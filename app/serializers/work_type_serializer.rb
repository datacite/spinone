class WorkTypeSerializer < ActiveModel::Serializer
  cache key: 'work_type'
  attributes :title, :container, :updated_at
end
