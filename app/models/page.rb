class Page < Base
  attr_reader :id, :author, :title, :container_title, :description, :license, :url, :image_url, :tags, :issued, :updated_at

  def initialize(attributes, options={})
    @id = attributes.fetch("@id")
    @author = attributes.fetch("author", []).map { |a| { "given" => a["givenName"],
                                                         "family" => a["familyName"],
                                                         "orcid" => a["@id"] } }
    @title = attributes.fetch("name", nil)
    @container_title = attributes.fetch("publisher", nil)
    @description = attributes.fetch("description", nil)
    @license = attributes.fetch("license", nil)
    @url = attributes.fetch("url", nil)
    @image_url = attributes.fetch("image", nil)
    @tags = attributes.fetch("keywords", "").split(", ")
    @issued = attributes.fetch("datePublished", nil)
    @updated_at = @issued
  end

  def self.get_query_url(options={})
    url
  end

  def self.parse_data(result, options={})
    return nil if result.body.blank? || result.body['errors']

    items = result.body.fetch("data", [])

    if options[:id]
      item = items.find { |i| i["@id"] == options[:id] }
      return nil if item.nil?

      { data: parse_item(item) }
    else
      items = items.select { |i| i.values.join("\n").downcase.include?(options[:query]) } if options[:query]
      items = items.select { |i| i.fetch("keywords", "").split(", ").include?(options[:tag]) } if options[:tag]

      meta = { total: items.length, tags: parse_meta(items) }

      number = (options["page[number]"] || 1).to_i
      size = (options["page[size]"] || 25).to_i
      offset = (number - 1) * size
      items = items[offset...offset + size] || []

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
