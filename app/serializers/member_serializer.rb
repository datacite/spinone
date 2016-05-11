class MemberSerializer < ActiveModel::Serializer
  cache key: 'member'
  attributes :title, :description, :member_type, :region, :country, :year
end
