class PublisherSerializer < ActiveModel::Serializer
  cache key: 'publisher'
  attributes :title, :other_names, :prefixes, :registration_agency_id, :updated_at
end
