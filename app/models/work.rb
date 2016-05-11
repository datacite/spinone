class Work < Base
  attr_reader :id, :doi, :author, :title, :container_title, :description, :resource_type_general, :resource_type, :type, :license, :publisher_id, :published, :issued

  # include author methods
  include Authorable

  # include helper module for extracting identifier
  include Identifiable

  # include metadata helper methods
  include Metadatable

  def initialize(attributes)
    @doi = attributes.fetch("doi", nil)
    @id = doi_as_url(@doi)

    xml = Base64.decode64(attributes.fetch('xml', "PGhzaD48L2hzaD4=\n"))
    xml = Hash.from_xml(xml).fetch("resource", {})
    authors = xml.fetch("creators", {}).fetch("creator", [])
    authors = [authors] if authors.is_a?(Hash)
    @author = get_hashed_authors(authors)

    @title = attributes.fetch("title", []).first
    @container_title = attributes.fetch("publisher", nil)
    @description = attributes.fetch("description", []).first
    @published = attributes.fetch("publicationYear", nil)
    @issued =  attributes.fetch("minted", nil)
    @resource_type_general = attributes.fetch("resourceTypeGeneral", nil)
    @resource_type = attributes.fetch("resourceType", nil).presence || nil
    @type = DATACITE_TYPE_TRANSLATIONS[@resource_type_general]
    @license = attributes.fetch("rightsURI", []).first
    @publisher_id = attributes.fetch("datacentre_symbol", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      url + "?q=doi:" + options[:id]
    else
      sort = options[:sort].presence || options[:q].present? ? "score" : "minted"
      order = options[:order].presence || "desc"

      params = { q: options.fetch(:q, nil).presence || "*:*",
                 start: options.fetch(:offset, 0),
                 rows: options[:rows].presence || 25,
                 fl: "doi,title,description,publisher,publicationYear,resourceType,resourceTypeGeneral,rightsURI,datacentre_symbol,xml,minted,updated",
                 fq: "has_metadata:true AND is_active:true",
                 sort: "#{sort} #{order}",
                 wt: "json" }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    if options[:id]
      item = result.fetch("data", {}).fetch('response', {}).fetch('doc', {})
      return nil if item.blank?

      { data: parse_item(item) }
    else
      items = result.fetch("data", {}).fetch('response', {}).fetch('docs', [])
      total = result.fetch("data", {}).fetch("response", {}).fetch("numFound", 0)

      { data: parse_items(items), meta: { total: total } }
    end
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["SOLR_URL"]}"
  end
end
