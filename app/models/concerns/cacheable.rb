module Cacheable
  extend ActiveSupport::Concern

  module ClassMethods
    def cached_groups
      Rails.cache.fetch("groups", expires_in: 1.month) do
        Group.all[:data]
      end
    end

    def cached_members
      Rails.cache.fetch("members", expires_in: 1.day) do
        Member.all[:data]
      end
    end

    def cached_registration_agencies
      Rails.cache.fetch("registration_agencies", expires_in: 1.month) do
        RegistrationAgency.all[:data]
      end
    end

    def cached_relation_types
      Rails.cache.fetch("relation_types", expires_in: 1.month) do
        RelationType.all[:data]
      end
    end

    def cached_resource_types
      Rails.cache.fetch("resource_types", expires_in: 1.month) do
        ResourceType.all[:data]
      end
    end

    def cached_sources
      Rails.cache.fetch("sources", expires_in: 1.hour) do
        Source.all[:data]
      end
    end

    def cached_work_types
      Rails.cache.fetch("work_types", expires_in: 1.month) do
        WorkType.all[:data]
      end
    end

    def cached_lagotto_response(options={})
      Rails.cache.fetch("lagotto_response", expires_in: 1.day) do
        lagotto_query_url = get_lagotto_query_url(options)
        Maremma.get(lagotto_query_url, options)
      end
    end

    def cached_lagotto_member_response(id, options={})
      Rails.cache.fetch("lagotto_member_response/#{id}", expires_in: 1.day) do
        lagotto_query_url = get_lagotto_query_url(options)
        Maremma.get(lagotto_query_url, options)
      end
    end
  end
end
