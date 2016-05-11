class Publisher < Base
  attr_reader :id, :title, :other_names, :prefixes, :member_id, :registration_agency_id, :updated_at

  def initialize(attributes)
    @id = attributes.fetch("id", nil)
    @title = attributes.fetch("title", nil)
    @other_names = attributes.fetch("other_names", [])
    @prefixes = attributes.fetch("prefixes", [])
    @member_id = @id.split(".").first
    @registration_agency_id = attributes.fetch("registration_agency_id", nil)
    @updated_at = attributes.fetch("timestamp", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      params = { page: options.fetch(:offset, 1),
                 per_page: options.fetch(:rows, 25),
                 q: options.fetch(:q, nil),
                 registration_agency_id: options.fetch(:registration_agency_id, nil) }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    if options[:id]
      item = result.fetch("data", {}).fetch("publisher", {})
      return nil if item.blank?

      { data: parse_item(item) }
    else
      items = result.fetch("data", {}).fetch("publishers", [])
      meta = result.fetch("data", {}).fetch("meta", {}).except("status", "message-type", "message-version")

      { data: parse_items(items), meta: meta }
    end
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/publishers"
  end
end
