class Publisher < Base
  attr_reader :id, :title, :other_names, :prefixes, :member_id, :registration_agency_id, :updated_at

  def initialize(attributes)
    @id = attributes.fetch("id").underscore.dasherize
    @title = attributes.fetch("title", nil)
    @other_names = attributes.fetch("other_names", [])
    @prefixes = attributes.fetch("prefixes", [])
    @member_id = attributes.fetch("member_id", nil)
    @registration_agency_id = attributes.fetch("registration_agency_id", nil)
    @updated_at = attributes.fetch("timestamp", nil)
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
                 member_id: options.fetch("member-id", nil) }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    return nil if result.blank? || result['errors']

    if options[:id]
      item = result.fetch("data", {}).fetch("publisher", {})
      return nil if item.blank?

      member_id = item.fetch("member_id", nil)
      member = member_id.present? ? Member.where(id: member_id) : nil
      member = member[:data] if member.present?

      { data: parse_items([item]) + [member].compact }
    else
      items = result.fetch("data", {}).fetch("publishers", [])
      meta = result.fetch("data", {}).fetch("meta", {})
      meta = { total: meta.fetch("total", {}),
               registration_agencies: meta.fetch("registration_agencies", {}),
               members: meta.fetch("members", {}) }

      { data: parse_items(items) + parse_included(meta, options), meta: meta }
    end
  end

  def self.parse_included(meta, options={})
    Member.all[:data].select { |s| meta.fetch(:members, {}).has_key?(s.id.upcase) }
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/publishers"
  end
end
