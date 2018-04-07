class Page < Base
  attr_reader :id, :author, :title, :container_title, :description, :license, :url, :image_url, :tags, :issued, :updated

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
    @updated = @issued
  end

  def self.get_query_url(options={})
    url
  end

  def self.parse_data(result, options={})
    return nil if result.body.blank? || result.body['errors']

    items = result.body.fetch("data", [])

    if options[:id]
      item = items.find { |i| i["@id"] == "https://doi.org/" + options[:id] }
      return nil if item.nil?

      { data: parse_item(item) }
    else
      items = items.select { |i| (i.fetch("title", "").downcase + i.fetch("description", "").downcase).include?(options[:query]) } if options[:query]
      items = items.select { |i| i.fetch("keywords", "").split(", ").include?(options[:tag]) } if options[:tag]

      meta = { total: items.length, tags: parse_meta(items) }

      page = (options.dig(:page, :number) || 1).to_i
      per_page = options.dig(:page, :size) && (1..1000).include?(options.dig(:page, :size).to_i) ? options.dig(:page, :size).to_i : 25
      offset = (page - 1) * per_page
      items = items[offset...offset + per_page] || []

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
