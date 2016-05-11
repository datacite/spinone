class PublisherSerializer < ActiveModel::Serializer
  cache key: 'publisher'
  attributes :title, :other_names, :prefixes, :member_id, :registration_agency_id, :updated_at
end
