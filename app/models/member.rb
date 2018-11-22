class Member < Base
  attr_reader :id, :cache_key, :title, :description, :member_type, :region, :country, :year, :logo_url, :email, :website, :phone, :created, :updated

  def initialize(item, options={})
    attributes = item.fetch('attributes', {})
    @id = item.fetch("id", nil).downcase
    @title = attributes.fetch("name", nil)
    @description = ActionController::Base.helpers.sanitize(attributes.fetch("description", nil), tags: %w(strong em b i code pre sub sup br))
    @member_type = attributes.fetch("memberType", nil)
    @region = attributes.fetch("region", nil)
    @country = attributes.fetch("country", nil)
    @year = attributes.fetch("year", nil)
    @logo_url = attributes.fetch("logoUrl", nil)
    @website = attributes.fetch("website", nil)
    @email = attributes.fetch("email", nil)
    @phone = attributes.fetch("phone", nil)
    @created = attributes.fetch("created", nil)
    @updated = attributes.fetch("updated", nil)
    @cache_key = "member/#{@id}-#{@updated}"
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      params = { query: options.fetch(:query, nil),
                 region: options.fetch(:region, nil),
                 year: options.fetch(:year, nil),
                 "page[size]" => options.dig(:page, :size),
                 "page[number]" => options.dig(:page, :number) }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    return nil if result.body.blank? || result.body['errors']

    if options[:id].present?
      item = result.body.fetch("data", {})
      return nil unless item.present?

      { data: parse_item(item) }
    else
      items = result.body.fetch("data", [])
      meta = result.body.fetch("meta", {})

      { data: parse_items(items), meta: meta }
    end
  end

  def self.url
    "#{ENV["API_URL"]}/providers"
  end
end
