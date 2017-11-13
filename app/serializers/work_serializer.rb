class WorkSerializer < ActiveModel::Serializer
  cache key: 'work'
  attributes :doi, :identifier, :url, :author, :title, :container_title, :description, :resource_type_subtype, :data_center_id, :member_id, :resource_type_id, :version, :license, :schema_version, :results, :related_identifiers, :published, :registered, :updated, :media, :xml

  belongs_to :data_center, serializer: DataCenterSerializer
  belongs_to :member, serializer: MemberSerializer

  belongs_to :resource_type, serializer: ResourceTypeSerializer

  def id
    object.identifier
  end

  def media
    object.media.present? ? object.media.map { |m| { media_type: m.split(":", 2).first, url: m.split(":", 2).last }} : nil
  end

  def updated
    object.updated_at
  end
end
