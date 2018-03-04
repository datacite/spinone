class Work < Base
  attr_reader :id, :doi, :identifier, :cache_key, :url, :author, :title, :container_title, :description, :resource_type_subtype, :data_center_id, :member_id, :resource_type_id, :data_center, :member, :resource_type, :license, :version, :results, :related_identifiers, :schema_version, :xml, :media, :published, :registered, :updated

  # include author methods
  include Authorable

  # include helper module for extracting identifier
  include Identifiable

  # include metadata helper methods
  include Metadatable

  # include helper module for caching infrequently changing resources
  include Cacheable

  # include helper module for date calculations
  include Dateable

  def initialize(attributes={}, options={})
    @doi = attributes.fetch("doi", "").downcase.presence
    @identifier = attributes.fetch("id", nil).presence || doi_as_url(attributes.fetch("doi", nil))
    @id = @identifier

    @xml = attributes.fetch('xml', "PGhzaD48L2hzaD4=\n")
    @media = attributes.fetch('media', nil)
    @media = @media.map { |m| { media_type: m.split(":", 2).first, url: m.split(":", 2).last }} if @media.present?
    @author = get_authors(attributes.fetch("creator", nil))
    @url = attributes.fetch("url", nil)

    @title = ActionController::Base.helpers.sanitize(attributes.fetch("title", []).first, tags: %w(strong em b i code pre sub sup br))
    @container_title = attributes.fetch("publisher", nil)
    @description = ActionController::Base.helpers.sanitize(attributes.fetch("description", []).first, tags: %w(strong em b i code pre sub sup br)).presence || nil
    @published = attributes.fetch("publicationYear", nil)
    @registered = attributes.fetch("minted", nil)
    @updated = attributes.fetch("updated", nil)
    @resource_type_subtype = attributes.fetch("resourceType", nil).presence || nil
    @license = normalize_license(attributes.fetch("rightsURI", []))
    @version = attributes.fetch("version", nil)
    @schema_version = attributes.fetch("schema_version", nil)
    @related_identifiers = attributes.fetch('relatedIdentifier', [])
      .select { |id| id =~ /:DOI:.+/ }
      .map do |i|
        relation_type, _related_identifier_type, related_identifier = i.split(':', 3)
        { "relation-type-id" => relation_type,
          "related-identifier" => doi_as_url(related_identifier.upcase) }
      end
    @results = @related_identifiers.reduce({}) do |sum, i|
      k = i["relation-type-id"]
      v = sum[k].to_i + 1
      sum[k] = v
      sum
    end.map { |k,v| { id: k, title: k.underscore.humanize, count: v } }
      .sort { |a, b| b[:count] <=> a[:count] }
    @data_center_id = attributes.fetch("datacentre_symbol", nil)
    @data_center_id = @data_center_id.downcase if @data_center_id.present?
    @member_id = attributes.fetch("allocator_symbol", nil)
    @member_id = @member_id.downcase if @member_id.present?
    @resource_type_id = attributes.fetch("resourceTypeGeneral", nil)
    @resource_type_id = @resource_type_id.underscore.dasherize if @resource_type_id.present?

    # associations
    @data_center = Array(options[:data_centers]).find { |p| p.id == @data_center_id }
    @member = Array(options[:members]).find { |r| r.id == @member_id }
    @resource_type = Array(options[:resource_types]).find { |r| r.id == @resource_type_id }

    @cache_key = "works/#{@id}-#{@updated_at}"
  end

  def identifiers
    [{ "identifier" => "doi:#{doi}",
       "identifier-source" => "DataCite" }]
  end

  def types
    [{ "information" => { "value" => resource_type } }]
  end

  def creators
    author.map { |a| { "first-name" => a["given"], "last-name" => a["family"] } }
  end

  def dates
    [{ "date" => published,
       "type" => { "ontologyTermIRI" => "http://schema.datacite.org/meta/kernel-3.1/metadata.xsd", "value" => "publicationYear" }
     },
     { "date" => registered,
       "type" => { "ontologyTermIRI" => "http://schema.datacite.org/meta/kernel-3.1/metadata.xsd", "value" => "Issued" }
     },
     { "date" => updated,
       "type" => { "ontologyTermIRI" => "http://schema.datacite.org/meta/kernel-3.1/metadata.xsd", "value" => "Updated" }
     }]
  end

  def self.get_query_url(options={})
    if options[:id].present?
      params = { q: options[:id],
                 qf: "doi",
                 defType: "edismax",
                 wt: "json" }
    elsif options["work-id"].present?
      params = { q: options['work-id'],
                 qf: "doi",
                 fl: "doi,relatedIdentifier",
                 defType: "edismax",
                 wt: "json" }
    else
      if options[:ids].present?
        ids = options[:ids].split(",")[0..99]
        options[:query] = options[:query].to_s + " " + ids.join(" ")
        options[:qf] = "doi"
        options[:rows] = ids.length
        options[:sort] = "registered"
        options[:mm] = 1
      end

      if options[:sort].present?
        sort = case options[:sort]
               when "registered" then "minted"
               when "published" then "publicationYear"
               when "updated" then "updated"
               else "score"
               end
      else
        sort = options[:query].present? ? "score" : "minted"
      end
      order = options[:order] == "asc" ? "asc" : "desc"

      page = (options.dig(:page, :number) || 1).to_i
      per_page = (options.dig(:page, :size) || 25).to_i
      offset = (page - 1) * per_page

      created_date = options['from-created-date'].present? || options['until-created-date'].present?
      created_date = get_solr_date_range(options['from-created-date'], options['until-created-date']) if created_date

      update_date = options["from-update-date"].present? || options["until-update-date"].present?
      update_date = get_solr_date_range(options['from-update-date'], options['until-update-date']) if update_date
      registered = get_solr_date_range(options[:registered], options[:registered]) if options[:registered].present?

      fq = %w(has_metadata:true is_active:true)
      fq << "resourceTypeGeneral:#{options['resource-type-id'].underscore.camelize}" if options['resource-type-id'].present?
      fq << "datacentre_symbol:#{options['data-center-id'].upcase}" if options['data-center-id'].present?
      fq << "allocator_symbol:#{options['member-id'].upcase}" if options['member-id'].present?
      fq << "nameIdentifier:ORCID\\:#{options['person-id']}" if options['person-id'].present?
      fq << "minted:#{created_date}" if created_date
      fq << "updated:#{update_date}" if update_date
      fq << "minted:#{registered}" if registered
      fq << "publicationYear:#{options[:year]}" if options[:year].present?
      fq << "schema_version:#{options['schema-version']}" if options['schema-version'].present?

      params = { q: options.fetch(:query, nil).presence || "*:*",
                 start: offset,
                 rows: per_page,
                 fl: "doi,title,creator,description,publisher,publicationYear,resourceType,resourceTypeGeneral,rightsURI,version,datacentre_symbol,allocator_symbol,schema_version,xml,media,minted,updated",
                 qf: options[:qf],
                 fq: fq.join(" AND "),
                 facet: "true",
                 'facet.field' => %w(publicationYear datacentre_facet resourceType_facet schema_version minted),
                 'facet.limit' => 15,
                 'facet.mincount' => 1,
                 'facet.range' => 'minted',
                 'f.minted.facet.range.start' => '2004-01-01T00:00:00Z',
                 'f.minted.facet.range.end' => '2024-01-01T00:00:00Z',
                 'f.minted.facet.range.gap' => '+1YEAR',
                 sort: "#{sort} #{order}",
                 defType: "edismax",
                 bq: "updated:[NOW/DAY-1YEAR TO NOW/DAY]",
                 mm: options[:mm],
                 wt: "json" }.compact
    end

    url + "?" + URI.encode_www_form(params)
  end

  def self.get_data(options={})
    # sometimes don't query DataCite MDS
    return {} if (options["data-center-id"].present? && options["data-center-id"].exclude?("."))

    query_url = get_query_url(options)

    if Rails.logger.level < 2
      Librato.timing "doi.get_data" do
        Maremma.get(query_url, options)
      end
    else
      Maremma.get(query_url, options)
    end
  end

  def self.parse_data(result, options={})
    return result if result['errors']
    data = nil

    if options[:id].present?
      return nil if result.body.blank?

      items = result.body.fetch("data", {}).fetch('response', {}).fetch('docs', [])
      return nil if items.blank?

      item = items.first

      meta = result[:meta]

      resource_type = nil
      resource_type_id = item.fetch("resourceTypeGeneral", nil)
      resource_type = ResourceType.where(id: resource_type_id.downcase.underscore.dasherize) if resource_type_id.present?
      resource_type = resource_type[:data] if resource_type.present?

      data_center = nil
      data_center_id = item.fetch("datacentre_symbol", nil)
      data_center = DataCenter.where(id: data_center_id.downcase) if data_center_id.present?
      data_center = data_center[:data] if data_center.present?

      if Rails.logger.level < 2
        Librato.timing "doi.parse_item" do
          data = parse_item(item,
            resource_types: cached_resource_types,
            data_centers: [data_center].compact,
            members: cached_members)
        end
      else
        data = parse_item(item,
          resource_types: cached_resource_types,
          data_centers: [data_center].compact,
          members: cached_members)
      end

      { data: data, meta: meta }
    else
      if options["work-id"].present?
        return { data: [], meta: [] } if result.body.blank?

        items = result.body.fetch("data", {}).fetch('response', {}).fetch('docs', [])
        return { data: [], meta: [] } if items.blank?

        item = items.first
        related_doi_identifiers = item.fetch('relatedIdentifier', [])
                                      .select { |id| id =~ /:DOI:.+/ }
                                      .map { |i| i.split(':', 3).last.strip.upcase }
        return { data: [], meta: [] } if related_doi_identifiers.blank?

        options = options.except("work-id")
        query_url = get_query_url(options.merge(ids: related_doi_identifiers.join(",")))
        result = Maremma.get(query_url, options)
      end

      items = result.body.fetch("data", {}).fetch('response', {}).fetch('docs', [])

      facets = result.body.fetch("data", {}).fetch("facet_counts", {})

      page = (options.dig(:page, :number) || 1).to_i
      per_page = (options.dig(:page, :size) || 25).to_i
      offset = (page - 1) * per_page
      total = result.body.fetch("data", {}).fetch("response", {}).fetch("numFound", 0)
      total_pages = (total.to_f / per_page).ceil

      meta = parse_facet_counts(facets, options)
      meta = meta.merge(total: total, total_pages: total_pages, page: page)

      data_centers = facets.fetch("facet_fields", {}).fetch("datacentre_facet", [])
                       .each_slice(2)
                       .map do |p|
                              id, title = p.first.split(' - ', 2)
                              [DataCenter, { "id" => id, "title" => title }]
                            end
      data_centers = Array(data_centers).map do |item|
        parse_include(item.first, item.last)
      end

      if Rails.logger.level < 2
        Librato.timing "doi.parse_items" do
          data = parse_items(items,
            resource_types: cached_resource_types,
            data_centers: data_centers,
            members: cached_members)
        end
      else
        data = parse_items(items,
          resource_types: cached_resource_types,
          data_centers: data_centers,
          members: cached_members)
      end

      { data: data, meta: meta }
    end
  end

  def self.parse_facet_counts(facets, options={})
    resource_types = Array.wrap(facets.dig("facet_fields", "resourceType_facet"))
                           .each_slice(2)
                           .map { |k,v| { id: k.underscore.dasherize, title: k.underscore.humanize, count: v } }
    years = Array.wrap(facets.dig("facet_fields", "publicationYear"))
                  .each_slice(2)
                  .sort { |a, b| b.first <=> a.first }
                  .map { |i| { id: i[0], title: i[0], count: i[1] } }
    registered = Array.wrap(facets.dig("facet_ranges", "minted", "counts"))
                  .each_slice(2)
                  .sort { |a, b| b.first <=> a.first }
                  .map { |i| { id: i[0][0..3], title: i[0][0..3], count: i[1] } }
    data_centers = Array.wrap(facets.dig("facet_fields", "datacentre_facet"))
                       .each_slice(2)
                       .map do |p|
                              id, title = p.first.split(' - ', 2)
                              [id, p.last]
                            end.to_h
    data_centers = get_data_center_facets(data_centers)
    schema_versions = facets.fetch("facet_fields", {}).fetch("schema_version", [])
                            .each_slice(2)
                            .sort { |a, b| b.first <=> a.first }
                            .map { |i| { id: i[0], title: "Schema #{i[0]}", count: i[1] } }

    if options["data-center-id"].present? && data_centers.empty?
      data_centers = { options["data-center-id"] => 0 }
    end

    { "resource-types" => resource_types,
      "years" => years,
      "registered" => registered,
      "data_centers" => data_centers,
      "schema-versions" => schema_versions }
  end

  def self.get_data_center_facets(data_centers, options={})
    response = DataCenter.where(ids: data_centers.keys.join(","))
    response.fetch(:data, [])
            .map { |p| { id: p.id.downcase, title: p.name, count: data_centers.fetch(p.id.upcase, 0) } }
            .sort { |a, b| b[:count] <=> a[:count] }
  end

  def self.url
    "#{ENV["SOLR_URL"]}"
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
