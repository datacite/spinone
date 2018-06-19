class Work < Base
  attr_reader :id, :doi, :identifier, :cache_key, :url, :author, :title, :container_title, :description, :resource_type_subtype, :data_center_id, :member_id, :resource_type_id, :data_center, :member, :resource_type, :license, :version, :results, :related_identifiers, :schema_version, :xml, :media, :checked, :published, :registered, :updated

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
    @checked = attributes.fetch("checked", nil)
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
    @cache_key = "work/#{@id}-#{@updated}"
  end

  # associations
  def data_center
    cached_data_center_response(data_center_id.to_s.upcase) if data_center_id.present?
  end

  def member
    cached_member_response(member_id.to_s.upcase) if member_id.present?
  end

  def resource_type
    cached_resource_type_response(resource_type_id) if resource_type_id.present?
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
                 fq: "doi:#{options[:id].dump}" ,
                 defType: "edismax",
                 wt: "json" }
    elsif options[:work_id].present?
      params = { q: options[:work_id],
                 fl: "doi,relatedIdentifier",
                 defType: "edismax",
                 wt: "json" }
    else
      if options[:ids].present?
        ids = options[:ids].split(",")[0..99]
        options[:query] = options[:query].to_s + " " + ids.join(" ")
        options[:rows] = ids.length
        options[:sort] = "registered"
        options[:mm] = 1
      end

      if options[:sample].present?
        sort = Rails.env.test? ? "random_1234" : "random_#{rand(1...100000)}"
      elsif options[:sort].present?
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

      # grouping for sampling
      group = nil
      group_field = nil
      group_ngroups = nil
      group_format = nil
      group_limit = nil

      if options[:sample].present? && options[:sample_group].present?
        group_field = case options[:sample_group]
                      when "client" then "datacentre_symbol"
                      when "data-center" then "datacentre_symbol"
                      when "provider" then "allocator_symbol"
                      when "resource-type" then "resourceTypeGeneral"
                      else nil
                      end
        if group_field.present?
          group = "true"
          group_ngroups = "true"
          group_format = "simple"
          group_limit = (1..100).include?(options[:sample].to_i) ? options[:sample].to_i : 10
        else
          options.delete(:sample_group)
        end
      end

      page = (options.dig(:page, :number) || 1).to_i
      if options[:sample].present? && options[:sample_group].present?
        samples_per_page = (1..100).include?(options[:sample].to_i) ? options[:sample].to_i : 10
        per_page = options.dig(:page, :size).to_i * samples_per_page
        per_page = (1..1000).include?(per_page) ? per_page : 1000
      elsif options[:sample].present? && options[:sample_group].blank?
        per_page = (1..100).include?(options[:sample].to_i) ? options[:sample].to_i : 10
      else
        per_page = options.dig(:page, :size) && (1..1000).include?(options.dig(:page, :size).to_i) ? options.dig(:page, :size).to_i : 25
      end
      offset = (page - 1) * per_page

      created_date = options[:from_created_date].present? || options[:until_created_date].present?
      created_date = get_solr_date_range(options[:from_created_date], options[:until_created_date]) if created_date

      update_date = options[:from_update_date].present? || options[:until_update_date].present?
      update_date = get_solr_date_range(options[:from_update_date], options[:until_update_date]) if update_date
      registered = get_solr_date_range(options[:registered], options[:registered]) if options[:registered].present?
      checked = "(checked:[* TO #{get_datetime_from_input(options[:checked])}] OR (*:* NOT checked:[* TO *]))" if options[:checked].present?

      fq = %w(has_metadata:true is_active:true)
      fq << "resourceTypeGeneral:#{options[:resource_type_id].underscore.camelize}" if options[:resource_type_id].present?
      fq << "datacentre_symbol:#{options[:data_center_id].upcase}" if options[:data_center_id].present?
      fq << "allocator_symbol:#{options[:member_id].upcase}" if options[:member_id].present?
      fq << "nameIdentifier:ORCID\\:#{options[:person_id]}" if options[:person_id].present?
      fq << "minted:#{created_date}" if created_date
      fq << "updated:#{update_date}" if update_date
      fq << "checked:#{checked}" if checked
      fq << "minted:#{registered}" if registered
      fq << "publicationYear:#{options[:year]}" if options[:year].present?
      fq << "schema_version:#{options[:schema_version]}" if options[:schema_version].present?

      if options[:url].present?
        q = "url:#{options[:url]}"
      elsif options[:query].present?
        q = options[:query]
      else
        q = "*:*"
      end

      params = { q: q,
                 start: offset,
                 rows: per_page,
                 fl: "doi,url,title,creator,description,publisher,publicationYear,resourceType,resourceTypeGeneral,rightsURI,version,datacentre_symbol,allocator_symbol,schema_version,xml,media,minted,updated,checked",
                 fq: fq.join(" AND "),
                 facet: "true",
                 'facet.field' => %w(publicationYear datacentre_facet resourceType_facet schema_version minted),
                 'facet.limit' => 15,
                 'facet.mincount' => 1,
                 'facet.range' => 'minted',
                 'f.minted.facet.range.start' => '2004-01-01T00:00:00Z',
                 'f.minted.facet.range.end' => '2024-01-01T00:00:00Z',
                 'f.minted.facet.range.gap' => '+1YEAR',
                 group: group,
                 'group.field' => group_field,
                 'group.ngroups' => group_ngroups,
                 'group.format' => group_format,
                 'group.limit' => group_limit,
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
    return {} if (options[:data_center_id].present? && options[:data_center_id].exclude?("."))

    query_url = get_query_url(options)
    Maremma.get(query_url, options)
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

      data = parse_item(item)

      { data: data, meta: meta }
    else
      if options[:work_id].present?
        return { data: [], meta: [] } if result.body.blank?

        items = result.body.fetch("data", {}).fetch('response', {}).fetch('docs', [])
        return { data: [], meta: [] } if items.blank?

        item = items.first
        related_doi_identifiers = item.fetch('relatedIdentifier', [])
                                      .select { |id| id =~ /:DOI:.+/ }
                                      .map { |i| i.split(':', 3).last.strip.upcase }
        return { data: [], meta: [] } if related_doi_identifiers.blank?

        options = options.except(:work_id)
        query_url = get_query_url(options.merge(ids: related_doi_identifiers.join(",")))
        result = Maremma.get(query_url, options)
      end

      # check for grouped samples
      if result.body.dig("data", "grouped").present?
        grouped = result.body.dig("data", "grouped")
        items = grouped.values[0].dig("doclist", "docs") || []
        total = grouped.values[0].fetch("ngroups", 0)
      else
        response = result.body.dig("data", "response")
        items = response.fetch('docs', [])
        total = response.fetch("numFound", 0)
      end

      facets = result.body.fetch("data", {}).fetch("facet_counts", {})

      page = (options.dig(:page, :number) || 1).to_i
      if options[:sample].present? && options[:sample_group].present?
        samples_per_page = (1..100).include?(options[:sample].to_i) ? options[:sample].to_i : 10
        per_page = options.dig(:page, :size).to_i * samples_per_page
        per_page = (1..1000).include?(per_page) ? per_page : 1000
      elsif options[:sample].present? && options[:sample_group].blank?
        per_page = (1..100).include?(options[:sample].to_i) ? options[:sample].to_i : 10
      else
        per_page = options.dig(:page, :size) && (1..1000).include?(options.dig(:page, :size).to_i) ? options.dig(:page, :size).to_i : 25
      end
      offset = (page - 1) * per_page

      total_pages = (total.to_f / per_page).ceil

      meta = parse_facet_counts(facets, options)
      meta = meta.merge(total: total, "total-pages" => total_pages, page: page)

      data_centers = facets.fetch("facet_fields", {}).fetch("datacentre_facet", [])
                       .each_slice(2)
                       .map do |p|
                              id, title = p.first.split(' - ', 2)
                              [DataCenter, { "id" => id, "title" => title }]
                            end
      data_centers = Array(data_centers).map do |item|
        parse_include(item.first, item.last)
      end

      data = parse_items(items)

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

    if options[:data_center_id].present? && data_centers.empty?
      dc = DataCenter.where(id: options[:data_center_id])
      return [] unless dc[:data].present?

      data_centers = [{ "id" => options[:data_center_id].upcase,
                        "title" => dc[:data].name,
                        "count" => 0 }]
    end

    { "resource-types" => resource_types,
      "years" => years,
      "registered" => registered,
      "data-centers" => data_centers,
      "schema-versions" => schema_versions }
  end

  def self.get_data_center_facets(data_centers, options={})
    return [] unless data_centers.present?

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
