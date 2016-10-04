class PublisherSerializer < ActiveModel::Serializer
  attributes :title, :other_names, :prefixes, :updated

  belongs_to :member, serializer: MemberSerializer
  belongs_to :registration_agency, serializer: RegistrationAgencySerializer

  def updated
    object.updated_at
  end
end
