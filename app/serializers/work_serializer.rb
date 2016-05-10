class WorkSerializer < ActiveModel::Serializer
  cache key: 'work'
  attributes :id, :title
end
