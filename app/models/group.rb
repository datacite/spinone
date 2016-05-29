class Group < Base
  attr_reader :id, :title, :sources, :updated_at

  def initialize(attributes)
    @id = attributes.fetch("id").underscore.dasherize
    @title = attributes.fetch("title", nil)
    @sources = attributes.fetch("sources", [])
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
    return nil if result.blank? || result['errors']

    if options[:id]
      item = result.fetch("data", {}).fetch("group", {})
      return nil if item.blank?

      { data: parse_item(item) }
    else
      items = result.fetch("data", {}).fetch("groups", [])
      total = result.fetch("data", {}).fetch("meta", {}).fetch("total", nil)

      { data: parse_items(items), meta: { total: total } }
    end
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/groups"
  end
end
