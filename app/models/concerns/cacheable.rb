module Cacheable
  extend ActiveSupport::Concern

  module ClassMethods
    def cached_members
      Rails.cache.fetch("members", expires_in: 1.day) do
        member = Member.all
        member.present? ? member[:data] : []
      end
    end

    def cached_resource_types
      Rails.cache.fetch("resource_types", expires_in: 1.month) do
        ResourceType.all[:data]
      end
    end
  end
end
