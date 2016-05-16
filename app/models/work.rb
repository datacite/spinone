class Work < Base
  attr_reader :id, :doi, :author, :title, :container_title, :description, :resource_type_general, :resource_type, :type, :license, :publisher_id, :published, :issued

  # include author methods
  include Authorable

  # include helper module for extracting identifier
  include Identifiable

  # include metadata helper methods
  include Metadatable

  def initialize(attributes)
    @doi = attributes.fetch("doi")
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
    @resource_type_general = @resource_type_general.underscore.dasherize if @resource_type_general.present?
    @resource_type = attributes.fetch("resourceType", nil).presence || nil
    @type = DATACITE_TYPE_TRANSLATIONS[@resource_type_general]
    @license = attributes.fetch("rightsURI", []).first
    @publisher_id = attributes.fetch("datacentre_symbol", nil)
    @publisher_id = @publisher_id.underscore.dasherize if @publisher_id.present?
  end

  def self.get_query_url(options={})
    if options[:id].present?
      url + "?q=doi:" + options[:id]
    else
      sort = options[:sort].presence || options[:q].present? ? "score" : "minted"
      order = options[:order].presence || "desc"
      fq = %w(has_metadata:true is_active:true)
      fq << "resourceTypeGeneral:#{options['resource-type-id']}" if options['resource-type-id'].present?
      fq << "datacentre_symbol:#{options['publisher-id']}" if options['publisher-id'].present?

      params = { q: options.fetch(:q, nil).presence || "*:*",
                 start: options.fetch(:offset, 0),
                 rows: options[:rows].presence || 25,
                 fl: "doi,title,description,publisher,publicationYear,resourceType,resourceTypeGeneral,rightsURI,datacentre_symbol,xml,minted,updated",
                 fq: fq,
                 facet: "true",
                 'facet.field' => %w(publicationYear datacentre_facet resourceType_facet),
                 'facet.limit' => 10,
                 'f.resourceType_facet.facet.limit' => 15,
                 'facet.mincount' => 1,
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
      facets = result.fetch("data", {}).fetch("facet_counts", {}).fetch("facet_fields", {})

      included = parse_included(facets, options)
      meta = parse_facet_counts(facets, options)
      meta[:total] = result.fetch("data", {}).fetch("response", {}).fetch("numFound", 0)

      { data: parse_items(items) + parse_included(facets), meta: meta }
    end
  end

  def self.parse_included(facets, options={})
    resource_types = facets.fetch("resourceType_facet", [])
                           .each_slice(2)
                           .map { |r| [ResourceType, { "id" => r.first,
                                                       "title" => r.first.underscore.humanize }] }

    publishers = facets.fetch("datacentre_facet", [])
                       .each_slice(2)
                       .map do |p|
                              id, title = p.first.split(' - ', 2)
                              [Publisher, { "id" => id, "title" => title }]
                            end

    if options["publisher-id"].present? && publishers.empty?
      publisher = Publisher.where(id: options["publisher-id"])[:data]
      publishers = [[Publisher, { "id" => publisher.id, "title" => publisher.title }]]
    end

    Array(resource_types).map do |item|
      parse_include(item.first, item.last)
    end
  end

  def self.parse_include(klass, params)
    klass.new(params)
  end

  def self.parse_facet_counts(facets, options={})
    resource_types = facets.fetch("resourceType_facet", []).each_slice(2).to_h
    years = facets.fetch("publicationYear", []).each_slice(2).to_h
    publishers = facets.fetch("datacentre_facet", [])
                       .each_slice(2)
                       .map do |p|
                              id, title = p.first.split(' - ', 2)
                              [id, p.last]
                            end.to_h

    if options["publisher-id"].present? && publishers.empty?
      publishers = { options["publisher-id"] => 0 }
    end

    { "resource-types" => resource_types,
      "years" => years,
      "publishers" => publishers }
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["SOLR_URL"]}"
  end
end
