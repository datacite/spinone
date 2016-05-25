class WorkTypeSerializer < ActiveModel::Serializer
  cache key: 'work_type'
  attributes :title, :container, :updated

  def updated
    object.updated_at
  end
end
