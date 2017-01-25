class DataCenterSerializer < ActiveModel::Serializer
  attributes :title, :other_names, :prefixes, :member_id, :registration_agency_id, :year, :created, :updated

  belongs_to :member, serializer: MemberSerializer
  belongs_to :registration_agency, serializer: RegistrationAgencySerializer
end
