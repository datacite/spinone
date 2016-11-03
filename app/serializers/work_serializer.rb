class WorkSerializer < ActiveModel::Serializer
  cache key: 'work'
  attributes :doi, :url, :author, :title, :container_title, :description, :resource_type_subtype, :publisher_id, :member_id, :registration_agency_id, :resource_type_id, :work_type_id, :license, :schema_version, :results, :published, :deposited, :updated

  belongs_to :publisher, serializer: PublisherSerializer
  belongs_to :member, serializer: MemberSerializer
  belongs_to :registration_agency, serializer: RegistrationAgencySerializer

  belongs_to :resource_type, serializer: ResourceTypeSerializer
  belongs_to :work_type, serializer: WorkTypeSerializer

  def updated
    object.updated_at
  end
end
