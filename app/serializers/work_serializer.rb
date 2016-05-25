class WorkSerializer < ActiveModel::Serializer
  cache key: 'work'
  attributes :author, :title, :container_title, :description, :published, :issued, :updated, :doi, :resource_type_general, :resource_type, :type, :license, :publisher_id

  def updated
    object.updated_at
  end
end
