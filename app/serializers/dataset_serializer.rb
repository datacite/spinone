class DatasetSerializer
  include FastJsonapi::ObjectSerializer

  attributes :identifiers, :title, :types, :creators, :dates, :container_title, :description

  set_type :dats
end
