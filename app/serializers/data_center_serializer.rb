class DataCenterSerializer < ActiveModel::Serializer
  attributes :title, :member_id, :year, :created, :updated

  belongs_to :member, serializer: MemberSerializer

  def title
    object.name
  end
end
