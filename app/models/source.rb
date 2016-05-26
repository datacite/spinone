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
      "#{url}/#{options[:id]}"
    else
      url
    end
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    if options[:id]
      item = result.fetch("data", {}).fetch("source", {})
      return nil if item.blank?

      { data: parse_item(item) }
    else
      items = result.fetch("data", {}).fetch("sources", [])
      total = result.fetch("data", {}).fetch("meta", {}).fetch("total", nil)

      { data: parse_items(items), meta: { total: total } }
    end
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/sources"
  end
end
