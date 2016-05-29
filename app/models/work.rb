class Work < Base
  attr_reader :id, :doi, :author, :title, :container_title, :description, :resource_type_general, :resource_type, :type, :license, :publisher_id, :member_id, :registration_agency_id, :results, :published, :issued, :updated_at

  # include author methods
  include Authorable

  # include helper module for extracting identifier
  include Identifiable

  # include metadata helper methods
  include Metadatable

  def initialize(attributes)
    @doi = attributes.fetch("doi")
    @id = doi_as_url(@doi)

    @author = attributes.fetch("author", nil)
    if author.nil?
      xml = Base64.decode64(attributes.fetch('xml', "PGhzaD48L2hzaD4=\n"))
      xml = Hash.from_xml(xml).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])
      authors = [authors] if authors.is_a?(Hash)
      @author = get_hashed_authors(authors)
    end

    @title = attributes.fetch("title", []).first
    @container_title = attributes.fetch("publisher", nil)
    @description = attributes.fetch("description", []).first
    @published = attributes.fetch("publicationYear", nil)
    @issued = attributes.fetch("minted", nil)
    @updated_at = attributes.fetch("updated", nil)
    @resource_type_general = attributes.fetch("resourceTypeGeneral", nil)
    @type = attributes.fetch("work_type_id", nil).presence || DATACITE_TYPE_TRANSLATIONS[@resource_type_general]
    @resource_type_general = @resource_type_general.underscore.dasherize if @resource_type_general.present?
    @resource_type = attributes.fetch("resourceType", nil).presence || nil
    @license = normalize_license(attributes.fetch("rightsURI", []))
    @publisher_id = attributes.fetch("datacentre_symbol", nil)
    @publisher_id = @publisher_id.underscore.dasherize if @publisher_id.present?
    @registration_agency_id = attributes.fetch("registration_agency_id", nil).presence || "datacite"
    @member_id = attributes.fetch("allocator_symbol", nil)
    @member_id = @member_id.underscore.dasherize if @member_id.present?
    @results = attributes.fetch("results", {})
  end

  def self.get_query_url(options={})
    if options[:id].present?
      params = { q: "doi:#{options[:id]}",
                 wt: "json" }
    else
      sort = options[:sort].presence || options[:q].present? ? "score" : "minted"
      order = options[:order].presence || "desc"
      fq = %w(has_metadata:true is_active:true)
      fq << "resourceTypeGeneral:#{options['resource-type-id']}" if options['resource-type-id'].present?
      fq << "datacentre_symbol:#{options['publisher-id']}" if options['publisher-id'].present?
      fq << "allocator_symbol:#{options['member-id']}" if options['member-id'].present?

      params = { q: options.fetch(:q, nil).presence || "*:*",
                 start: options.fetch(:offset, 0),
                 rows: options[:rows].presence || 25,
                 fl: "doi,title,description,publisher,publicationYear,resourceType,resourceTypeGeneral,rightsURI,datacentre_symbol,allocator_symbol,xml,minted,updated",
                 fq: fq,
                 facet: "true",
                 'facet.field' => %w(publicationYear datacentre_facet resourceType_facet),
                 'facet.limit' => 10,
                 'f.resourceType_facet.facet.limit' => 15,
                 'facet.mincount' => 1,
                 sort: "#{sort} #{order}",
                 wt: "json" }.compact
    end

    url + "?" + URI.encode_www_form(params)
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    if options[:id]
      return nil if result.blank?

      items = result.fetch("data", {}).fetch('response', {}).fetch('docs', [])
      item = get_results(items, options).first
      return nil if item.blank?

      sources = get_sources([item], options)
      publisher = Publisher.where(id: item.fetch("datacentre_symbol", nil))
      publisher = publisher[:data] if publisher.present?
      member = Member.where(id: item.fetch("allocator_symbol", nil))
      member = member[:data] if member.present?

      { data: parse_items([item]) + [publisher].compact + [member].compact + sources }
    else
      items = result.fetch("data", {}).fetch('response', {}).fetch('docs', [])
      items = get_results(items, options)
      sources = get_sources(items, options)
      facets = result.fetch("data", {}).fetch("facet_counts", {}).fetch("facet_fields", {})

      meta = parse_facet_counts(facets, options)
      meta[:total] = result.fetch("data", {}).fetch("response", {}).fetch("numFound", 0)

      { data: parse_items(items) + parse_included(facets, options) + sources, meta: meta }
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

  # fetch results hash from Event Data server
  # merge with hash from MDS
  def self.get_results(items, options={})
    return items unless ENV["LAGOTTO_URL"].present?

    if items.present?
      dois = items.map { |item| CGI.escape(item.fetch("doi")) }
      data = "ids=" + dois.join(",") + "&type=doi"
    elsif options[:id].present?
      data = "ids=" + CGI.escape(options[:id]) + "&type=doi"
    else
      return items
    end

    response = Maremma.post(lagotto_url, data: data, headers: { 'X-HTTP-Method-Override' => 'GET' }, content_type: 'html', token: ENV['LAGOTTO_TOKEN'])
    return items if response.fetch("data", {}).fetch("meta", {}).fetch("status", nil) == "error"

    if items.present?
      items.map do |item|
        work = response.fetch("data", {}).fetch("works", []).find { |r| r["DOI"] == item["doi"] }
        if work.present?
          item.merge("results" => work.fetch("results", {}))
        else
          item
        end
      end
    else
      item = response.fetch("data", {}).fetch("works", []).first

      [{ "id" => item.fetch("id"),
         "doi" => item.fetch("DOI", nil),
         "url" => item.fetch("URL", nil),
         "author" => item.fetch("author", []),
         "title" => [item.fetch("title", nil)],
         "publisher" => item.fetch("container-title", nil),
         "datacentre_symbol" => item.fetch("publisher_id", nil),
         "allocator_symbol" => item.fetch("member_id", nil),
         "registration_agency_id" => item.fetch("registration_agency_id", nil),
         "work_type_id" => item.fetch("work_type_id", nil),
         "results" => item.fetch("results", {}),
         "publicationYear" => item.fetch("published", nil),
         "minted" => item.fetch("issued", nil),
         "updated" => item.fetch("updated", nil)
      }]
    end
  end

  def self.get_sources(items, options={})
    used_sources = items.map { |item| item.fetch("results", {}).keys.map { |k| k.underscore.dasherize } }.flatten.uniq
    sources = Source.all[:data].select { |s| used_sources.include?(s.id) }
  end

  def self.url
    "#{ENV["SOLR_URL"]}"
  end

  def self.lagotto_url
    "#{ENV['LAGOTTO_URL']}/works"
  end

  # find Creative Commons or OSI license in rightsURI array
  def normalize_license(licenses)
    uri = licenses.map { |l| URI.parse(l) }.find { |l| l.host && l.host[/(creativecommons.org|opensource.org)$/] }
    return nil unless uri.present?

    # use HTTPS
    uri.scheme = "https"

    # use host name without subdomain
    uri.host = Array(/(creativecommons.org|opensource.org)/.match uri.host).last

    # normalize URLs
    if uri.host == "creativecommons.org"
      uri.path = uri.path.split('/')[0..-2].join("/") if uri.path.split('/').last == "legalcode"
      uri.path << '/' unless uri.path.end_with?('/')
    else
      uri.path = uri.path.gsub(/(-license|\.php|\.html)/, '')
      uri.path = uri.path.sub(/(mit|afl|apl|osl|gpl|ecl)/) { |match| match.upcase }
      uri.path = uri.path.sub(/(artistic|apache)/) { |match| match.titleize }
      uri.path = uri.path.sub(/([^0-9\-]+)(-)?([1-9])?(\.)?([0-9])?$/) do
        m = Regexp.last_match
        text = m[1]

        if m[3].present?
          version = [m[3], m[5].presence || "0"].join(".")
          [text, version].join("-")
        else
          text
        end
      end
    end

    uri.to_s
  end
end
