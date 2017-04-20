class DataCenterSerializer < ActiveModel::Serializer
  attributes :title, :other_names, :prefixes, :member_id, :year, :created, :updated

  belongs_to :member, serializer: MemberSerializer
end
