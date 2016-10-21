class PublisherSerializer < ActiveModel::Serializer
  attributes :title, :other_names, :prefixes, :member_id, :registration_agency_id, :updated

  belongs_to :member, serializer: MemberSerializer
  belongs_to :registration_agency, serializer: RegistrationAgencySerializer

  def updated
    object.updated_at
  end
end
