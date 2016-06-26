class WorkSerializer < ActiveModel::Serializer
  cache key: 'work'
  attributes :doi, :url, :author, :title, :container_title, :description, :resource_type_general, :resource_type, :type, :license, :publisher_id, :member_id, :registration_agency_id, :results, :published, :deposited, :updated

  def updated
    object.updated_at
  end
end
