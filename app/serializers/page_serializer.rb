class PageSerializer < ActiveModel::Serializer
  attributes :author, :title, :container_title, :description, :license, :image_url, :tags, :issued, :updated

  def updated
    object.updated_at
  end
end
