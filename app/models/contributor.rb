class Contributor < Base
  attr_reader :id, :given, :family, :literal, :updated_at

  def initialize(attributes)
    @id = attributes.fetch("id", nil)
    @given = attributes.fetch("given", nil)
    @family = attributes.fetch("family", nil)
    @literal = attributes.fetch("literal", nil)
    @updated_at = attributes.fetch("timestamp", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      params = { page: options.fetch(:offset, 1),
                 per_page: options.fetch(:rows, 25),
                 q: options.fetch(:q, nil) }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    if options[:id]
      item = result.fetch("data", {}).fetch("contributor", {})
      return nil if item.blank?

      { data: parse_item(item) }
    else
      items = result.fetch("data", {}).fetch("contributors", [])
      total = result.fetch("data", {}).fetch("meta", {}).fetch("total", nil)

      { data: parse_items(items), meta: { total: total } }
    end
  end

  def self.parse_items(items)
    Array(items).map do |item|
      parse_item(item)
    end
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/contributors"
  end
end
