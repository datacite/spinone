class WorkSerializer
  include FastJsonapi::ObjectSerializer

  cache_options enabled: true, cache_length: 8.hours

  attributes :id, :doi, :identifier, :url, :author, :title, :container_title, :description, :resource_type_subtype, :data_center_id, :member_id, :resource_type_id, :version, :license, :schema_version, :results, :related_identifiers, :published, :registered, :updated, :media, :xml

  belongs_to :data_center
  belongs_to :member
  belongs_to :resource_type
end
