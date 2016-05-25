class ResourceType < Base
  attr_reader :id, :title, :updated_at

  def initialize(attributes)
    @id = attributes.fetch("id").underscore.dasherize
    @title = attributes.fetch("title", nil)
    @updated_at = DATACITE_SCHEMA_DATE
  end

  def self.get_query_url(options={})
    "http://schema.datacite.org/meta/kernel-#{DATACITE_VERSION}/include/datacite-resourceType-v#{DATACITE_VERSION}.xsd"
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    items = result.fetch("data", {}).fetch("schema", {}).fetch("simpleType", {}).fetch('restriction', {}).fetch('enumeration', [])

    if options[:id]
      item = items.find { |i| i["value"] == options[:id] }
      return nil if item.nil?

      { data: parse_item(item) }
    else
      { data: parse_items(items), meta: { total: items.length } }
    end
  end

  def self.parse_item(item)
    id = item.fetch("value")
    title = id.underscore.humanize
    self.new("id" => id, "title" => title)
  end
end
