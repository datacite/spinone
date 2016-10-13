class Publisher < Base
  attr_reader :id, :title, :other_names, :prefixes, :member, :registration_agency, :updated_at, :publisher_id, :ids

  # include helper module for caching infrequently changing resources
  include Cacheable

  def initialize(attributes, options={})
    @id = attributes.fetch("id").underscore.dasherize
    @title = attributes.fetch("title", nil)
    @other_names = attributes.fetch("other_names", [])
    @prefixes = attributes.fetch("prefixes", [])
    @publisher_id = attributes.fetch("publisher_id", nil)
    @ids = attributes.fetch("ids", nil)
    @updated_at = attributes.fetch("timestamp", nil)

    # associations
    @member = Array(options[:members]).find { |s| s.id.upcase == attributes.fetch("member_id", nil) }
    @registration_agency = Array(options[:registration_agencies]).find { |s| s.id == attributes.fetch("registration_agency_id", nil) }
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      offset = options.fetch(:offset, 0).to_f
      page = (offset / 25).ceil + 1

      params = { page: page,
                 per_page: options.fetch(:rows, 25),
                 q: options.fetch(:query, nil),
                 registration_agency_id: options.fetch("registration-agency-id", nil),
                 publisher_id: options.fetch("publisher-id", nil),
                 ids: options.fetch(:ids, nil),
                 member_id: options.fetch("member-id", nil) }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    return nil if result.blank? || result['errors']

    if options[:id]
      item = result.fetch("data", {}).fetch("publisher", {})
      return nil if item.blank?

      { data: parse_item(item, members: cached_members, registration_agencies: cached_registration_agencies) }
    else
      items = result.fetch("data", {}).fetch("publishers", [])
      meta = result.fetch("data", {}).fetch("meta", {})
      meta = { total: meta.fetch("total", {}),
               registration_agencies: meta.fetch("registration_agencies", {}),
               members: meta.fetch("members", {}) }

      { data: parse_items(items, members: cached_members, registration_agencies: cached_registration_agencies), meta: meta }
    end
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/publishers"
  end
end
