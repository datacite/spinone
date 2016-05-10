class Work < Base
  attr_reader :id, :title, :other_names, :prefixes, :registration_agency_id, :updated_at

  def initialize(attributes)
    @id = attributes.fetch("id", nil)
    @title = attributes.fetch("title", nil)
    @other_names = attributes.fetch("other_names", [])
    @prefixes = attributes.fetch("prefixes", [])
    @registration_agency_id = attributes.fetch("registration_agency_id", nil)
    @updated_at = attributes.fetch("timestamp", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      params = { q: q,
                 start: options.fetch(:offset, 0),
                 rows: options[:rows].presence || 25,
                 fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,relatedIdentifier,nameIdentifier,xml,minted,updated",
                 fq: "has_metadata:true AND is_active:true",
                 wt: "json" }
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
      items = result.fetch("data", {}).fetch("works", [])
      total = result.fetch("data", {}).fetch("meta", {}).fetch("total", nil)

      { data: parse_items(items), meta: { total: total } }
    end
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/works"
  end
end
