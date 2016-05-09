class RelationType < Base
  attr_reader :id, :title

  def initialize(id, title)
    @id = id
    @title = title
  end

  def self.get_query_url(options={})
    "http://schema.datacite.org/meta/kernel-#{DATACITE_VERSION}/include/datacite-relationType-v#{DATACITE_VERSION}.xsd"
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    items = result.fetch("data", {}).fetch("schema", {}).fetch("simpleType", {}).fetch('restriction', {}).fetch('enumeration', [])

    if options[:id]
      item = items.find { |i| i["value"] == options[:id] }
      return nil if item.nil?

      parse_item(item)
    else
      parse_items(items)
    end
  end

  def self.parse_items(items)
    Array(items).map do |item|
      parse_item(item)
    end
  end

  def self.parse_item(item)
    id = item.fetch("value", "missing value")
    title = id.underscore.humanize
    self.new(id, title)
  end
end
