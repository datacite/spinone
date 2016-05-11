class Member < Base
  attr_reader :id, :title, :description, :member_type, :region, :country, :year

  def initialize(item)
    attributes = item.fetch('attributes', {})
    @id = item.fetch("id", nil)
    @title = attributes.fetch("title", nil)
    @description = attributes.fetch("description", nil)
    @member_type = attributes.fetch("member-type", nil)
    @region = attributes.fetch("region", nil)
    @country = attributes.fetch("country", nil)
    @year = attributes.fetch("year", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      params = { q: options.fetch(:q, nil),
                 member_type: options.fetch(:member_type, nil),
                 region: options.fetch(:region, nil),
                 year: options.fetch(:year, nil) }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    if options[:id]
      item = result.fetch("data", {})
      return nil if item.blank?

      { data: parse_item(item) }
    else
      items = result.fetch("data", [])
      meta = result.fetch("meta", {}).except("total-pages", "page")

      { data: parse_items(items), meta: meta }
    end
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["VOLPINO_URL"]}/members"
  end
end
