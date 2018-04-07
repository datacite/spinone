class WorkSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash

  set_type :works
  cache_options enabled: true, cache_length: 8.hours
  attributes :doi, :identifier, :url, :author, :title, :container_title, :description, :resource_type_subtype, :data_center_id, :member_id, :resource_type_id, :version, :license, :schema_version, :results, :related_identifiers, :published, :registered, :checked, :updated, :media, :xml

  belongs_to :data_center, record_type: "data-centers", serializer: :DataCenter
  belongs_to :member, record_type: :members, serializer: :Member
  belongs_to :resource_type, record_type: "resource-types", serializer: :ResourceType
end
