class DatasetSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  
  attributes :identifiers, :title, :types, :creators, :dates, :container_title, :description

  set_type :dats
end
