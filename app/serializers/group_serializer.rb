class GroupSerializer < ActiveModel::Serializer
  cache key: 'group'
  attributes :title, :sources, :updated

  def updated
    object.updated_at
  end
end
