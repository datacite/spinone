class DataCenterSerializer
  include FastJsonapi::ObjectSerializer

  cache_options enabled: true, cache_length: 12.hours
  set_type "data-centers"
  attributes :title, :member_id, :year, :created, :updated

  belongs_to :member, record_type: :members, serializer: :Member
end
