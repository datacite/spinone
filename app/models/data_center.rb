class DataCenter < Base
  attr_reader :id, :name, :prefixes, :member_id, :ids, :year, :created, :updated, :member, :cache_key

  # include helper module for caching infrequently changing resources
  include Cacheable

  def initialize(item, options={})
    attributes = item.fetch('attributes', {})
    @id = item.fetch("id", nil).downcase
    @name = attributes.fetch("name", nil)
    @year = attributes.fetch("year", nil)
    @created = attributes.fetch("created", nil)
    @updated = attributes.fetch("updated", nil)
    @prefixes = attributes.fetch("prefixes", [])

    @member_id = @id.split('.', 2).first
    @member_id = @member_id.downcase if @member_id.present?

    @cache_key = "data-center/#{@id}-#{@updated}"
  end

  alias_attribute :title, :name

  # associations
  def member
    cached_member_response(member_id.to_s.upcase)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      params = { query: options.fetch(:query, nil),
                 ids: options.fetch(:ids, nil),
                 year: options.fetch(:year, nil),
                 "provider-id": options.fetch(:member_id, nil),
                 "page[size]" => options.dig(:page, :size),
                 "page[number]" => options.dig(:page, :number),
                 include: "provider" }.compact
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
    "#{ENV["APP_URL"]}/clients"
  end
end
