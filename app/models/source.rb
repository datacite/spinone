class Source < Base
  attr_reader :id, :title, :description, :state, :group, :group_id, :work_count, :relation_count, :result_count, :by_day, :by_month, :updated_at

  # include helper module for caching infrequently changing resources
  include Cacheable

  def initialize(attributes, options={})
    @id = attributes.fetch("id").underscore.dasherize
    @title = attributes.fetch("title", nil)
    @description = attributes.fetch("description", nil)
    @state = attributes.fetch("state", nil)
    @work_count = attributes.fetch("work_count", 0)
    @relation_count = attributes.fetch("relation_count", 0)
    @result_count = attributes.fetch("result_count", 0)
    @by_day = attributes.fetch("by_day", {})
    @by_month = attributes.fetch("by_month", {})
    @group_id = attributes.fetch("group_id", {})
    @updated_at = attributes.fetch("timestamp", nil)

    # associations
    @group = Array(options[:groups]).find { |s| s.id == @group_id }
  end

  def self.get_query_url(options={})
    if options[:id].present?
      id = options[:id].underscore
      "#{url}/#{id}"
    else
      params = { q: options.fetch(:query, nil),
                 group_id: options.fetch("group-id", nil) }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    return nil if result.blank? || result['errors']

    if options[:id]
      item = result.fetch("data", {}).fetch("source", {})
      return nil if item.blank?

      { data: parse_item(item, groups: cached_groups) }
    else
      items = result.fetch("data", {}).fetch("sources", [])

      meta = result.fetch("data", {}).fetch("meta", {})
      meta = { total: meta["total"], groups: meta["groups"] }

      { data: parse_items(items, groups: cached_groups), meta: meta }
    end
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/sources"
  end
end
