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

    def cached_lagotto_response(options={})
      Rails.cache.fetch("lagotto_response", expires_in: 1.day) do
        lagotto_query_url = get_lagotto_query_url(options)
        Maremma.get(lagotto_query_url, options)
      end
    end

    def cached_lagotto_resource_type_response(id, options={})
      Rails.cache.fetch("lagotto_resource_type_response/#{id}", expires_in: 1.day) do
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

    def cached_members_response(options={})
      Rails.cache.fetch("member_response", expires_in: 1.day) do
        Base::DB[:allocator].select(:id, :symbol, :name, :created).all
      end
    end

    def cached_member_response(id, options={})
      Rails.cache.fetch("member_response/#{id}", expires_in: 1.day) do
        Base::DB[:allocator].where(symbol: id).select(:id, :symbol, :name, :created).first
      end
    end

    def cached_data_center_response(id, options={})
      Rails.cache.fetch("data_center_response/#{id}", expires_in: 1.day) do
        data = self.ds.where(symbol: id).first
        { "data" => { "data-center" => data } }
      end
    end

    def cached_total_response(options={})
      Rails.cache.fetch("total_response", expires_in: 1.day) do
        query = self.ds.where{(is_active = true) & (allocator > 100)}
        query.count
      end
    end

    def cached_years_response(options={})
      Rails.cache.fetch("years_response", expires_in: 1.day) do
        query = self.ds.where{(is_active = true) & (allocator > 100)}
        years = query.group_and_count(Sequel.extract(:year, :created)).all
        years.map { |y| { id: y.values.first.to_s, title: y.values.first.to_s, count: y.values.last } }
             .sort { |a, b| b.fetch(:id) <=> a.fetch(:id) }
      end
    end

    def cached_years_by_member_response(id, options={})
      Rails.cache.fetch("years_response", expires_in: 1.day) do
        query = self.ds.where(is_active: true, allocator: id)
        years = query.group_and_count(Sequel.extract(:year, :created)).all
        years.map { |y| { id: y.values.first.to_s, title: y.values.first.to_s, count: y.values.last } }
             .sort { |a, b| b.fetch(:id) <=> a.fetch(:id) }
      end
    end

    def cached_allocators_response(options={})
      Rails.cache.fetch("allocator_response", expires_in: 1.day) do
        query = self.ds.where{(is_active = true) & (allocator > 100)}
        allocators = query.group_and_count(:allocator).all.map { |a| { id: a[:allocator], count: a[:count] } }
        members = cached_members_response
        members = (allocators + members).group_by { |h| h[:id] }.map { |k,v| v.reduce(:merge) }.select { |h| h[:count].present? }
      end
    end

    def cached_data_centers_response(options={})
      Rails.cache.fetch("data_center_response", expires_in: 1.day) do
        query = self.ds.where{(is_active = true) & (allocator > 100)}
        query.limit(25).offset(0).order(:name)
      end
    end

    def cached_data_centers_by_member_response(id, options={})
      Rails.cache.fetch("data_center_by_member_response/#{id}", expires_in: 1.day) do
        query = self.ds.where(is_active: true, allocator: id)
        query.limit(25).offset(0).order(:name)
      end
    end
  end
end
