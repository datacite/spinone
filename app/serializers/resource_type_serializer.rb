class ResourceTypeSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  
  set_type "resource-types"
  cache_options enabled: true, cache_length: 1.month
  attributes :title, :updated
end
