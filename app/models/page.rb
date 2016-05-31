class Page < Base
  attr_reader :id, :author, :title, :container_title, :description, :tags, :issued, :updated_at

  def initialize(attributes)
    @id = attributes.fetch("url").underscore.dasherize
    @author = attributes.fetch("author", nil)
    @title = attributes.fetch("title", nil)
    @container_title = attributes.fetch("container_title", nil)
    @description = attributes.fetch("description", nil)
    @tags = attributes.fetch("tags", [])
    @issued = attributes.fetch("issued", nil)
    @updated_at = @issued
  end

  def self.get_query_url(options={})
    url
  end

  def self.parse_data(result, options={})
    return nil if result.blank? || result['errors']

    items = result.fetch("data", [])

    if options[:id]
      item = items.find { |i| i["url"] == "https://#{options[:id]}/" }
      return nil if item.nil?

      { data: parse_item(item) }
    else
      items = items.select { |i| i.values.join("\n").downcase.include?(options[:q]) } if options[:q]
      items = items.select { |i| Array(i["tags"]).include?(options[:tag]) } if options[:tag]

      { data: parse_items(items), meta: { total: items.length } }
    end
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["BLOG_URL"]}/posts.json"
  end
end
