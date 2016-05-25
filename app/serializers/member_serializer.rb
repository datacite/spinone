class MemberSerializer < ActiveModel::Serializer
  cache key: 'member'
  attributes :title, :description, :member_type, :region, :country, :year, :updated

  def updated
    object.updated_at
  end
end
