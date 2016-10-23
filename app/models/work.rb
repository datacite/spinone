class Work < Base
  attr_reader :id, :doi, :url, :author, :title, :container_title, :description, :resource_type_subtype, :publisher_id, :member_id, :registration_agency_id, :resource_type_id, :work_type_id, :publisher, :member, :registration_agency, :resource_type, :work_type, :license, :results, :schema_version, :published, :deposited, :updated_at

  # include author methods
  include Authorable

  # include helper module for extracting identifier
  include Identifiable

  # include metadata helper methods
  include Metadatable

  # include helper module for caching infrequently changing resources
  include Cacheable

  def initialize(attributes={}, options={})
    @id = attributes.fetch("id", nil).presence || doi_as_url(attributes.fetch("doi", nil))

    @author = attributes.fetch("author", nil)
    if author.nil?
      xml = Base64.decode64(attributes.fetch('xml', "PGhzaD48L2hzaD4=\n"))
      xml = Hash.from_xml(xml).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])
      authors = [authors] if authors.is_a?(Hash)
      @author = get_hashed_authors(authors)
    end

    @doi = attributes.fetch("doi", nil)
    @url = attributes.fetch("url", nil)
    @title = attributes.fetch("title", []).first
    @container_title = attributes.fetch("publisher", nil)
    @description = attributes.fetch("description", []).first
    @published = attributes.fetch("publicationYear", nil)
    @deposited = attributes.fetch("minted", nil)
    @updated_at = attributes.fetch("updated", nil)
    @resource_type_subtype = attributes.fetch("resourceType", nil).presence || nil
    @license = normalize_license(attributes.fetch("rightsURI", []))
    @schema_version = attributes.fetch("schema_version", nil)
    @results = attributes.fetch("results", {})

    @publisher_id = attributes.fetch("datacentre_symbol", nil)
    @publisher_id = @publisher_id.underscore.dasherize if @publisher_id.present?
    @member_id = attributes.fetch("allocator_symbol", nil)
    @member_id = @member_id.underscore.dasherize if @member_id.present?
    @registration_agency_id = @member_id.present? ? "datacite" : attributes.fetch("registration_agency_id", nil)
    @registration_agency_id = @registration_agency_id.underscore.dasherize if @registration_agency_id.present?
    @resource_type_id = attributes.fetch("resourceTypeGeneral", nil)
    @resource_type_id = @resource_type_id.underscore.dasherize if @resource_type_id.present?
    @work_type_id = attributes.fetch("work_type_id", nil).presence || DATACITE_TYPE_TRANSLATIONS[attributes["resourceTypeGeneral"]] || "work"
    @work_type_id = @work_type_id.underscore.dasherize if @work_type_id.present?

    # associations
    @publisher = Array(options[:publishers]).find { |p| p.id == @publisher_id }
    @member = Array(options[:members]).find { |r| r.id == @member_id }
    @registration_agency = Array(options[:registration_agencies]).find { |r| r.id == @registration_agency_id }
    @resource_type = Array(options[:resource_types]).find { |r| r.id == @resource_type_id }
    @work_type = Array(options[:work_types]).find { |r| r.id == @work_type_id }
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

      fq = %w(has_metadata:true is_active:true)
      fq << "resourceTypeGeneral:#{options['resource-type-id'].underscore.camelize}" if options['resource-type-id'].present?
      fq << "datacentre_symbol:#{options['publisher-id'].upcase}" if options['publisher-id'].present?
      fq << "allocator_symbol:#{options['member-id'].upcase}" if options['member-id'].present?
      fq << "publicationYear:#{options['year']}" if options['year'].present?
      fq << "schema_version:#{options['schema-version']}" if options['schema-version'].present?

      params = { q: options.fetch(:query, nil).presence || "*:*",
                 start: options.fetch(:offset, 0),
                 rows: options[:rows].presence || 25,
                 fl: "doi,title,description,publisher,publicationYear,resourceType,resourceTypeGeneral,rightsURI,datacentre_symbol,allocator_symbol,schema_version,xml,minted,updated",
                 fq: fq.join(" AND "),
                 facet: "true",
                 'facet.field' => %w(publicationYear datacentre_facet resourceType_facet schema_version),
                 'facet.limit' => 15,
                 'facet.mincount' => 1,
                 sort: "#{sort} #{order}",
                 wt: "json" }.compact
    end

    url + "?" + URI.encode_www_form(params)
  end

  def self.get_lagotto_query_url(options={})
    if options[:id].present?
      # workaround, as nginx and the rails router swallow double backslashes
      options[:id] = options[:id].gsub(/(http|https):\/+(\w+)/, '\1://\2')

      lagotto_url + "?id=" + CGI.escape(options[:id])
    else
      offset = options.fetch(:offset, 0).to_f
      page = (offset / 25).ceil + 1

      source_id = options.fetch("source-id", nil)
      source_id = source_id.underscore if source_id.present?

      resource_type_id = options.fetch("resource-type-id", nil)
      resource_type_id = resource_type_id.underscore if resource_type_id.present?

      relation_type_id = options.fetch("relation-type-id", nil)
      relation_type_id = relation_type_id.underscore if relation_type_id.present?

      publisher_id = options.fetch("publisher-id", nil)

      member_id = options.fetch("member-id", nil)

      sort = options.fetch("sort", nil)
      sort = sort.underscore if sort.present?

      params = { page: page,
                 per_page: options.fetch(:rows, 25),
                 source_id: source_id,
                 resource_type_id: resource_type_id,
                 relation_type_id: relation_type_id,
                 publisher_id: publisher_id,
                 member_id: member_id,
                 year: options.fetch(:year, nil),
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

      item = items.first

      meta = result[:meta]

      resource_type = nil
      resource_type_id = item.fetch("resourceTypeGeneral", nil)
      resource_type = ResourceType.where(id: resource_type_id.downcase.underscore.dasherize) if resource_type_id.present?
      resource_type = resource_type[:data] if resource_type.present?

      publisher = nil
      publisher_id = item.fetch("datacentre_symbol", nil)
      publisher = Publisher.where(id: publisher_id.downcase.underscore.dasherize) if publisher_id.present?
      publisher = publisher[:data] if publisher.present?

      { data: parse_item(item,
        relation_types: cached_relation_types,
        resource_types: cached_resource_types,
        work_types: cached_work_types,
        publishers: [publisher].compact,
        members: cached_members,
        registration_agencies: cached_registration_agencies,
        sources: cached_sources), meta: meta }
    elsif options["source-id"].present? || options["relation-type-id"].present? || (options["publisher-id"].present? && options["publisher-id"].exclude?("."))
      result = get_results([], options)
      items = result[:data]
      meta = result[:meta]

      publisher_ids = meta.fetch(:publishers, []).map { |i| i["id"] }.join(",")
      publishers = Publisher.collect_data(ids: publisher_ids).fetch(:data, [])

      { data: parse_items(items,
        relation_types: cached_relation_types,
        resource_types: cached_resource_types,
        work_types: cached_work_types,
        publishers: publishers,
        members: cached_members,
        registration_agencies: cached_registration_agencies,
        sources: cached_sources,), meta: meta }
    else
      items = result.fetch("data", {}).fetch('response', {}).fetch('docs', [])
      lagotto_result = get_results(items, options)
      items = lagotto_result[:data]

      facets = result.fetch("data", {}).fetch("facet_counts", {}).fetch("facet_fields", {})
      meta = parse_facet_counts(facets, options)
      meta[:total] = result.fetch("data", {}).fetch("response", {}).fetch("numFound", 0)
      meta[:sources] = lagotto_result.fetch(:meta, {}).fetch(:sources, [])
      meta[:relation_types] = lagotto_result.fetch(:meta, {}).fetch(:relation_types, [])

      publishers = facets.fetch("datacentre_facet", [])
                       .each_slice(2)
                       .map do |p|
                              id, title = p.first.split(' - ', 2)
                              [Publisher, { "id" => id, "title" => title }]
                            end
      publishers = Array(publishers).map do |item|
        parse_include(item.first, item.last)
      end

      { data: parse_items(items,
        relation_types: cached_relation_types,
        resource_types: cached_resource_types,
        work_types: cached_work_types,
        publishers: publishers,
        members: cached_members,
        registration_agencies: cached_registration_agencies,
        sources: cached_sources), meta: meta }
    end
  end

  def self.parse_facet_counts(facets, options={})
    resource_types = facets.fetch("resourceType_facet", [])
                           .each_slice(2)
                           .map { |k,v| { id: k.underscore.dasherize, title: k.underscore.humanize, count: v } }
    years = facets.fetch("publicationYear", [])
                  .each_slice(2)
                  .sort { |a, b| b.first <=> a.first }
                  .map { |i| { id: i[0], title: i[0], count: i[1] } }
    publishers = facets.fetch("datacentre_facet", [])
                       .each_slice(2)
                       .map do |p|
                              id, title = p.first.split(' - ', 2)
                              [id, p.last]
                            end.to_h
    publishers = get_publisher_facets(publishers)
    schema_versions = facets.fetch("schema_version", [])
                            .each_slice(2)
                            .sort { |a, b| b.first <=> a.first }
                            .map { |i| { id: i[0], title: "Schema #{i[0]}", count: i[1] } }

    if options["publisher-id"].present? && publishers.empty?
      publishers = { options["publisher-id"] => 0 }
    end

    { "resource-types" => resource_types,
      "years" => years,
      "publishers" => publishers,
      "schema-versions" => schema_versions }
  end

  # fetch results hash from Event Data server
  # merge with hash from MDS
  def self.get_results(items, options={})
    return { data: items } unless ENV["LAGOTTO_URL"].present?

    # cache meta hash if no query or filters
    if options[:query].present?
      response = { "data" => { "meta" => { "sources" => [], "publishers" => [], "relation_types" => [] } } }
    elsif options[:id].present? ||
          options['source-id'].present? ||
          options['relation-type-id'].present? ||
          options['resource-type-id'].present? ||
          options['publisher-id'].present? ||
          options[:year].present?

      lagotto_query_url = get_lagotto_query_url(options)
      response = Maremma.get(lagotto_query_url, options)
    elsif options['member-id'].present?
      response = cached_lagotto_member_response(options['member-id'], options)
    else
      response = cached_lagotto_response(options)
    end

    if items.present?
      dois = items.map { |item| CGI.escape(item.fetch("doi")) }
      data = "ids=" + dois.join(",") + "&type=doi"
      items_response = Maremma.post(lagotto_url, data: data, headers: { 'X-HTTP-Method-Override' => 'GET' }, content_type: 'html', token: ENV['LAGOTTO_TOKEN'])

      return items if items_response.fetch("data", {}).fetch("meta", {}).fetch("status", nil) == "error"

      data = items.map do |item|
        work = items_response.fetch("data", {}).fetch("works", []).find { |r| r["DOI"] == item["doi"] }
        if work.present?
          item.merge("results" => work.fetch("results", {}))
        else
          item
        end
      end

      meta = response.fetch("data", {}).fetch("meta", {})
      meta = { total: meta["total"],
               years: meta["years"],
               sources: meta["sources"].map { |i| { "id" => i["id"].underscore.dasherize, "title" => i["title"], "count" => i["count"] }},
               publishers: meta["publishers"].map { |i| { "id" => i["id"].underscore.dasherize, "title" => i["title"], "count" => i["count"] }},
               resource_types: Array(meta["resource_types"]).map { |i| { "id" => i["id"].underscore.dasherize, "title" => i["title"], "count" => i["count"] }},
               relation_types: Array(meta["relation_types"]).map { |i| { "id" => i["id"].underscore.dasherize, "title" => i["title"], "count" => i["count"] }} }.compact

      { data: data, meta: meta }
    elsif options[:id].present? || options["source-id"].present? || options["relation-type-id"].present? || (options["publisher-id"].present? && options["publisher-id"].exclude?("."))
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
               years: meta["years"],
               sources: meta["sources"].map { |i| { "id" => i["id"].underscore.dasherize, "title" => i["title"], "count" => i["count"] }},
               publishers: meta["publishers"].map { |i| { "id" => i["id"].underscore.dasherize, "title" => i["title"], "count" => i["count"] }},
               resource_types: meta["resource_types"].map { |i| { "id" => i["id"].underscore.dasherize, "title" => i["title"], "count" => i["count"] }},
               relation_types: meta["relation_types"].map { |i| { "id" => i["id"].underscore.dasherize, "title" => i["title"], "count" => i["count"] }} }.compact

      { data: data, meta: meta }
    else
      { data: [] }
    end
  end

  def self.get_publisher_facets(publishers, options={})
    query_url = ENV['LAGOTTO_URL'] + "/publishers?ids=" + publishers.keys.join(",")
    response = Maremma.get(query_url, options)
    response.fetch("data", {}).fetch("publishers", [])
            .map { |p| { id: p.fetch("id").underscore.dasherize, title: p.fetch("title"), count: publishers.fetch(p.fetch("id"), 0) } }
            .sort { |a, b| b[:count] <=> a[:count] }
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
