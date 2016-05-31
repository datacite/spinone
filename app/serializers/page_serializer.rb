class PageSerializer < ActiveModel::Serializer
  cache key: 'page'
  attributes :author, :title, :container_title, :description, :tags, :issued, :updated

  def updated
    object.updated_at
  end
end
