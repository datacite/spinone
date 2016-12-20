class Page < Base
  attr_reader :id, :author, :title, :container_title, :description, :license, :image_url, :tags, :issued, :updated_at

  def initialize(attributes, options={})
    @id = attributes.fetch("@id")
    @author = attributes.fetch("author", []).map { |a| { "given" => a["givenName"],
                                                         "family" => a["familyName"],
                                                         "orcid" => a["@id"] } }
    @title = attributes.fetch("name", nil)
    @container_title = attributes.fetch("publisher", nil)
    @description = attributes.fetch("description", nil)
    @license = attributes.fetch("license", nil)
    @image_url = attributes.fetch("image", nil)
    @tags = attributes.fetch("keywords", "").split(", ")
    @issued = attributes.fetch("datePublished", nil)
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
      items = items.select { |i| i.values.join("\n").downcase.include?(options[:query]) } if options[:query]
      items = items.select { |i| Array(i["tags"]).include?(options[:tag]) } if options[:tag]

      meta = { total: items.length, tags: parse_meta(items) }

      offset = (options[:offset] || 0).to_i
      rows = (options[:rows] || 25).to_i
      items = items[offset...offset + rows]

      { data: parse_items(items), meta: meta }
    end
  end

  def self.parse_meta(items)
    items.reduce({}) do |sum, i|
      i.fetch("keywords", "").split(", ").each { |tag| sum[tag] = sum[tag].to_i + 1 }
      sum
    end.sort_by {|_key, value| -value}[0..14].to_h
  end

  def self.url
    "#{ENV["BLOG_URL"]}/posts.json"
  end
end
