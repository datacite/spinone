# this class generates metadata in DATS format
# https://biocaddie.org/group/working-group/working-group-3-descriptive-metadata-datasets

class Dataset < Base
  attr_reader :id, :doi, :author, :title, :container_title, :description, :resource_type_general, :subject, :resource_type, :license, :publisher_id, :member_id, :registration_agency_id, :results, :published, :deposited, :updated_at

  # include author methods
  include Authorable

  # include helper module for extracting identifier
  include Identifiable

  # include metadata helper methods
  include Metadatable

  def initialize(attributes)
    @id = attributes.fetch("id", nil).presence || doi_as_url(attributes.fetch("doi"))

    @author = attributes.fetch("author", nil)
    if author.nil?
      xml = Base64.decode64(attributes.fetch('xml', "PGhzaD48L2hzaD4=\n"))
      xml = Hash.from_xml(xml).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])

      authors = [authors] if authors.is_a?(Hash)
      @author = get_hashed_authors(authors)
    end

    @doi = attributes.fetch("doi", nil)
    @title = attributes.fetch("title", []).first
    @container_title = attributes.fetch("publisher", nil)
    @description = attributes.fetch("description", []).first
    @subject = attributes.fetch("subject", []).first
    @published = attributes.fetch("publicationYear", nil)
    @deposited = attributes.fetch("minted", nil)
    @updated_at = attributes.fetch("updated", nil)
    @resource_type_general = attributes.fetch("resourceTypeGeneral", nil)
    @resource_type_general = @resource_type_general.underscore.dasherize if @resource_type_general.present?
    @resource_type = attributes.fetch("resourceType", nil).presence || nil
    @license = normalize_license(attributes.fetch("rightsURI", []))
    @publisher_id = attributes.fetch("datacentre_symbol", nil)
    @publisher_id = @publisher_id.underscore.dasherize if @publisher_id.present?
    @member_id = attributes.fetch("allocator_symbol", nil)
    @member_id = @member_id.underscore.dasherize if @member_id.present?
    @registration_agency_id = @member_id.present? ? "datacite" : attributes.fetch("registration_agency_id", nil)
    @results = attributes.fetch("results", {})
  end

  def self.get_query_url(options={})
    if options[:id].present?
      params = { q: "doi:#{options[:id]}",
                 wt: "json" }
    else
      if options[:sort].present?
        sort = case options[:sort]
               when "deposited" then "minted"
               when "published" then "publicationYear"
               when "updated" then "updated"
               else "score"
               end
      else
        sort = options[:query].present? ? "score" : "minted"
      end
      order = options[:order] == "asc" ? "asc" : "desc"
      publisher_id = options['publisher-id'].presence || "cdl.tcia"
      fq = %w(has_metadata:true is_active:true)
      fq << "resourceTypeGeneral:#{options['resource-type-id'].underscore.camelize}" if options['resource-type-id'].present?
      fq << "datacentre_symbol:#{publisher_id}"

      params = { q: options.fetch(:query, nil).presence || "*:*",
                 start: options.fetch(:offset, 0),
                 rows: options[:rows].presence || 1000,
                 fl: "doi,title,description,publisher,publicationYear,resourceType,resourceTypeGeneral,rightsURI,datacentre_symbol,allocator_symbol,xml,minted,updated",
                 fq: fq.join(" AND "),
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

  def self.get_lagotto_query_url(options={})
    if options[:id].present?
      # workaround, as nginx and the rails router swallow double backslashes
      options["id"] = options["id"].gsub(/(http|https):\/+(\w+)/, '\1://\2')

      lagotto_url + "?id=" + CGI.escape(options[:id])
    else
      offset = options.fetch(:offset, 0).to_f
      page = (offset / 25).ceil + 1

      source_id = options.fetch("source-id", nil)
      source_id = source_id.underscore if source_id.present?

      relation_type_id = options.fetch("relation-type-id", nil)
      relation_type_id = relation_type_id.underscore if relation_type_id.present?

      publisher_id = options.fetch("publisher-id", nil)

      sort = options.fetch("sort", nil)
      sort = sort.underscore if sort.present?

      params = { page: page,
                 per_page: options.fetch(:rows, 25),
                 source_id: source_id,
                 relation_type_id: relation_type_id,
                 publisher_id: publisher_id,
                 sort: sort }.compact
      lagotto_url + "?" + URI.encode_www_form(params)
    end
  end

  def self.get_data(options={})
    # sometimes don't query DataCite MDS
    return {} if options["source-id"].present? ||
                 (options["publisher-id"].present? && options["publisher-id"].exclude?("."))

    query_url = get_query_url(options)
    Maremma.get(query_url, options)
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    if options[:id].present?
      return nil if result.blank?

      items = result.fetch("data", {}).fetch('response', {}).fetch('docs', [])
      result = get_results(items, options)
      items = result[:data]
      return nil if items.blank?

      meta = result[:meta]
      item = items.first

      publisher_id = item.fetch("datacentre_symbol", nil)
      publishers = Publisher.where(id: publisher_id)
      publishers = publishers.present? ? publishers[:data] : []

      member_id = item.fetch("allocator_symbol", nil)
      member = member_id.present? ? Member.where(id: member_id) : nil
      member = member[:data] if member.present?

      { data: parse_items([item]) + publishers + [member].compact + parse_lagotto_included(items, meta, options), meta: meta }
    elsif options["source-id"].present? || (options["publisher-id"].present? && options["publisher-id"].exclude?("."))
      result = get_results(result, options)
      items = result[:data]
      meta = result[:meta]

      { data: parse_items(items) + parse_lagotto_included(items, meta, options), meta: meta }
    else
      items = result.fetch("data", {}).fetch('response', {}).fetch('docs', [])
      items = get_results(items, options)[:data]
      sources = get_sources(items)
      facets = result.fetch("data", {}).fetch("facet_counts", {}).fetch("facet_fields", {})

      meta = { total: result.fetch("data", {}).fetch("response", {}).fetch("numFound", 0) }

      { data: parse_items(items), meta: meta }
    end
  end

  def self.parse_included(facets, options={})
    resource_types = facets.fetch("resourceType_facet", [])
                           .each_slice(2)
                           .map { |r| [ResourceType, { "id" => r.first,
                                                       "title" => r.first.underscore.humanize }] }
    resource_types = Array(resource_types).map do |item|
      parse_include(item.first, item.last)
    end

    publishers = facets.fetch("datacentre_facet", [])
                       .each_slice(2)
                       .map do |p|
                              id, title = p.first.split(' - ', 2)
                              [Publisher, { "id" => id, "title" => title }]
                            end
    publishers = Array(publishers).map do |item|
      parse_include(item.first, item.last)
    end

    if options["publisher-id"].present? && publishers.empty?
      publishers = Publisher.where(id: options["publisher-id"])
      publishers = publishers[:data] if publishers.present?
    end

    resource_types + publishers
  end

  def self.parse_lagotto_included(items, meta, options={})
    included = get_work_types(items)
    included += Source.all[:data].select { |s| meta.fetch(:sources, {}).has_key?(s.id.underscore) }
    included += RelationType.all[:data].select { |s| meta.fetch(:relation_types).has_key?(s.id.underscore) }
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
    return { data: items } unless ENV["LAGOTTO_URL"].present?

    if items.present?
      dois = items.map { |item| CGI.escape(item.fetch("doi")) }
      data = "ids=" + dois.join(",") + "&type=doi"
      response = Maremma.post(lagotto_url, data: data, headers: { 'X-HTTP-Method-Override' => 'GET' }, content_type: 'html', token: ENV['LAGOTTO_TOKEN'])

      return items if response.fetch("data", {}).fetch("meta", {}).fetch("status", nil) == "error"

      data = items.map do |item|
        work = response.fetch("data", {}).fetch("works", []).find { |r| r["DOI"] == item["doi"] }
        if work.present?
          item.merge("results" => work.fetch("results", {}))
        else
          item
        end
      end

      meta = response.fetch("data", {}).fetch("meta", {})
      meta = { total: meta["total"],
               sources: meta["sources"],
               relation_types: meta["relation_types"] }.compact

      { data: data, meta: meta }
    elsif options[:id].present? || options["source-id"].present? || (options["publisher-id"].present? && options["publisher-id"].exclude?("."))
      lagotto_query_url = get_lagotto_query_url(options)
      response = Maremma.get(lagotto_query_url, options)

      data = response.fetch("data", {}).fetch("works", []).map do |item|
        { "id" => item.fetch("id"),
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
          "updated" => item.fetch("updated", nil) }
      end

      meta = response.fetch("data", {}).fetch("meta", {})
      meta = { total: meta["total"],
               sources: meta["sources"],
               relation_types: meta["relation_types"] }.compact

      { data: data, meta: meta }
    else
      { data: [] }
    end
  end

  def self.get_sources(items)
    used_sources = items.map { |item| item.fetch("results", {}).keys.map { |k| k.underscore.dasherize } }.flatten.uniq
    Source.all[:data].select { |s| used_sources.include?(s.id) }
  end

  def self.get_work_types(items)
    used_work_types = items.map { |item| item.fetch("work_type_id", nil) }.compact
    WorkType.all[:data].select { |s| used_work_types.include?(s.id) }
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
  rescue URI::InvalidURIError
    nil
  end
end
