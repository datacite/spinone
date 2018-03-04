module Cacheable
  extend ActiveSupport::Concern

  included do
    def cached_member_response(id)
      Rails.cache.fetch("member_response/#{id}", expires_in: 12.hours) do
        member = Member.where(id: id)
        member.present? ? member[:data] : nil
      end
    end

    def cached_resource_type_response(id)
      Rails.cache.fetch("resource_type_response/#{id}", expires_in: 1.month) do
        resource_type = ResourceType.where(id: id)
        resource_type.present? ? resource_type[:data] : nil
      end
    end

    def cached_data_center_response(id)
      Rails.cache.fetch("data_center_response/#{id}", expires_in: 12.hours) do
        data_center = DataCenter.where(id: id)
        data_center.present? ? data_center[:data] : nil
      end
    end
  end
end
