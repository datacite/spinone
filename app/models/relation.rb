class Relation < Base
  attr_reader :id, :subj_id, :obj_id, :doi, :author, :title, :container_title, :source_id, :publisher_id, :registration_agency_id, :relation_type_id, :type, :total, :published, :issued, :updated_at

  # include helper module for extracting identifier
  include Identifiable

  def initialize(attributes)
    @id = SecureRandom.uuid
    @subj_id = attributes.fetch("subj_id")
    @obj_id = attributes.fetch("obj_id")

    @doi = doi_from_url(attributes.fetch("subj_id"))
    @author = attributes.fetch("author", nil)
    @title = attributes.fetch("title", nil)
    @container_title = attributes.fetch("container-title", nil)
    @source_id = attributes.fetch("source_id").underscore.dasherize
    @publisher_id = attributes.fetch("publisher_id")
    @registration_agency_id = attributes.fetch("registration_agency_id", nil)
    @relation_type_id = attributes.fetch("relation_type_id").underscore.dasherize
    @total = attributes.fetch("total", nil)
    @published = attributes.fetch("published", nil)
    @issued = attributes.fetch("issued", nil)
    @updated_at = attributes.fetch("timestamp", nil)
    @type = DATACITE_TYPE_TRANSLATIONS[@resource_type_general]
  end

  def self.get_query_url(options={})
    offset = options.fetch(:offset, 0).to_f
    page = (offset / 25).ceil + 1

    source_id = options.fetch("source-id", nil)
    source_id = source_id.underscore if source_id.present?

    params = { page: page,
               per_page: options.fetch(:rows, 25),
               q: options.fetch(:q, nil),
               relation_type_id: options.fetch("relation-type-id", nil),
               work_id: options.fetch("work-id", nil),
               work_ids: options.fetch("work-ids", nil),
               source_id: source_id }.compact
    url + "?" + URI.encode_www_form(params)
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    items = result.fetch("data", {}).fetch("relations", [])

    meta = parse_facet_counts(items, options)
    meta[:total] = result.fetch("data", {}).fetch("meta", {}).fetch("total", nil)

    { data: parse_items(items) + parse_included(items, options), meta: meta }
  end

  def self.parse_included(items, options={})
    used_sources = items.map { |i| i.fetch("source_id").underscore.dasherize }.uniq
    used_relation_types = items.map { |i| i.fetch("relation_type_id").underscore.dasherize }.uniq

    sources = Source.all[:data].select { |s| used_sources.include?(s.id) }
    sources + RelationType.all[:data].select { |s| used_relation_types.include?(s.id) }
  end

  def self.parse_facet_counts(items, options={})
    sources = items.group_by { |i| i["source_id"] }.reduce({}) do |sum, (k, v)|
      sum[k] = v.count
      sum
    end

    { "sources" => sources }
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/relations"
  end
end
