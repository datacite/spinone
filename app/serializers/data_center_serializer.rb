class DataCenterSerializer
  include FastJsonapi::ObjectSerializer

  cache_options enabled: true, cache_length: 12.hours

  attributes :id, :title, :member_id, :year, :created, :updated

  belongs_to :member
end
