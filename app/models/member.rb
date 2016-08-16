class Member < Base
  attr_reader :id, :title, :description, :member_type, :region, :country, :year, :logo_url, :email, :website, :phone, :updated_at

  def initialize(item)
    attributes = item.fetch('attributes', {})
    @id = item.fetch("id", nil).underscore
    @title = attributes.fetch("title", nil)
    @description = attributes.fetch("description", nil)
    @member_type = attributes.fetch("member-type", nil)
    @region = attributes.fetch("region", nil)
    @country = attributes.fetch("country", nil)
    @year = attributes.fetch("year", nil)
    @logo_url = attributes.fetch("logo-url", nil)
    @website = attributes.fetch("website", nil)
    @email = attributes.fetch("email", nil)
    @phone = attributes.fetch("phone", nil)
    @updated_at = attributes.fetch("updated", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      params = { query: options.fetch(:query, nil),
                 member_type: options.fetch("member-type", nil),
                 region: options.fetch(:region, nil),
                 year: options.fetch(:year, nil) }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    Rails.logger.info result
    return nil if result.blank? || result['errors']

    if options[:id].present?
      item = result.fetch("data", {})
      return {} unless item.present?

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
