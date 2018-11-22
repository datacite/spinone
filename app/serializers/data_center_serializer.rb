class DataCenterSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  set_type "data-centers"

  attributes :title, :member_id, :year, :created, :updated

  belongs_to :member, record_type: :members, serializer: :Member
end
