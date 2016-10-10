class WorkSerializer < ActiveModel::Serializer
  cache key: 'work'
  attributes :doi, :url, :author, :title, :container_title, :description, :resource_type_subtype, :license, :schema_version, :results, :published, :created, :updated

  belongs_to :resource_type, serializer: ResourceTypeSerializer
  belongs_to :work_type, serializer: WorkTypeSerializer
  belongs_to :publisher, serializer: PublisherSerializer

  def updated
    object.updated_at
  end
end
