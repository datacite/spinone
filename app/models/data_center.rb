class DataCenter < Base
  attr_reader :id, :name, :prefixes, :data_center_id, :member_id, :ids, :member, :year, :created, :updated

  # include helper module for caching infrequently changing resources
  include Cacheable

  def initialize(item, options={})
    attributes = item.fetch('attributes', {})
    @id = item.fetch("id", nil).downcase
    @name = attributes.fetch("name", nil)
    @created_at = attributes.fetch("created", nil)
    @updated_at = attributes.fetch("updated", nil)
    @prefixes = attributes.fetch("prefixes", [])

    @member_id = @id.split('.', 2).first
    @member_id = @member_id.downcase if @member_id.present?

    # associations
    @member = Array(options[:members]).find { |s| s.id == @member_id }
  end

  alias_attribute :title, :name

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      params = { query: options.fetch(:query, nil),
                 ids: options.fetch(:ids, nil),
                 year: options.fetch(:year, nil),
                 "provider-id": options.fetch("provider-id", nil),
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
    "#{ENV["LUPO_URL"]}/clients"
  end
end
