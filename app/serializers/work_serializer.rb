class WorkSerializer < ActiveModel::Serializer
  cache key: 'work'
  attributes :doi, :url, :author, :title, :container_title, :description, :resource_type_subtype, :data_center_id, :member_id, :registration_agency_id, :resource_type_id, :work_type_id, :version, :license, :schema_version, :results, :published, :deposited, :updated, :media, :xml

  belongs_to :data_center, serializer: DataCenterSerializer
  belongs_to :member, serializer: MemberSerializer
  belongs_to :registration_agency, serializer: RegistrationAgencySerializer

  belongs_to :resource_type, serializer: ResourceTypeSerializer
  belongs_to :work_type, serializer: WorkTypeSerializer

  def media
    object.media.present? ? object.media.map { |m| { media_type: m.split(":", 2).first, url: m.split(":", 2).last }} : nil
  end

  def updated
    object.updated_at
  end
end
