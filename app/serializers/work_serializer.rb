class WorkSerializer < ActiveModel::Serializer
  cache key: 'work'
  attributes :author, :title, :container_title, :description, :published, :issued, :doi, :resource_type_general, :resource_type, :type, :license, :publisher_id
end
