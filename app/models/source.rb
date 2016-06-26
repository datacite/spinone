class Source < Base
  attr_reader :id, :title, :description, :state, :group_id, :work_count, :relation_count, :result_count, :by_day, :by_month, :updated_at

  def initialize(attributes)
    @id = attributes.fetch("id").underscore.dasherize
    @title = attributes.fetch("title", nil)
    @description = attributes.fetch("description", nil)
    @state = attributes.fetch("state", nil)
    @group_id = attributes.fetch("group_id", nil)
    @work_count = attributes.fetch("work_count", 0)
    @relation_count = attributes.fetch("relation_count", 0)
    @result_count = attributes.fetch("result_count", 0)
    @by_day = attributes.fetch("by_day", {})
    @by_month = attributes.fetch("by_month", {})
    @updated_at = attributes.fetch("timestamp", nil)
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

      group = Group.where(id: item.fetch("group_id", nil))
      group = group[:data] if group.present?

      { data: parse_items([item]) + [group] }
    else
      items = result.fetch("data", {}).fetch("sources", [])

      meta = result.fetch("data", {}).fetch("meta", {})
      meta = { total: meta["total"], groups: meta["groups"] }

      { data: parse_items(items) + parse_included(items, options), meta: meta }
    end
  end

  def self.parse_included(items, options={})
    used_groups = items.map { |i| i.fetch("group_id").underscore.dasherize }.uniq
    groups = Group.all[:data].select { |s| used_groups.include?(s.id) }
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/sources"
  end
end
