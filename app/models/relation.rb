class Relation < Base
  attr_reader :id, :subj_id, :obj_id, :doi, :author, :title, :container_title, :source, :publisher_id, :registration_agency_id, :relation_type, :work_type, :total, :published, :issued, :updated_at

  # include helper module for extracting identifier
  include Identifiable

  # include helper module for caching infrequently changing resources
  include Cacheable

  def initialize(attributes, options={})
    @id = SecureRandom.uuid
    @subj_id = attributes.fetch("subj_id")
    @obj_id = attributes.fetch("obj_id")

    @doi = doi_from_url(attributes.fetch("subj_id"))
    @author = attributes.fetch("author", nil)
    @title = attributes.fetch("title", nil)
    @container_title = attributes.fetch("container-title", nil)
    @publisher_id = attributes.fetch("publisher_id", nil)
    @registration_agency_id = attributes.fetch("registration_agency_id", nil)
    @total = attributes.fetch("total", nil)
    @published = attributes.fetch("published", nil)
    @issued = attributes.fetch("issued", nil)
    @updated_at = attributes.fetch("timestamp", nil)
    @work_type = DATACITE_TYPE_TRANSLATIONS[@resource_type_general]

    # associations
    @source = Array(options[:sources]).find { |s| s.id.underscore == attributes.fetch("source_id", nil) }
    @relation_type = Array(options[:relation_types]).find { |r| r.id.underscore == attributes.fetch("relation_type_id", nil) }
  end

  def self.get_query_url(options={})
    offset = options.fetch(:offset, 0).to_f
    page = (offset / 25).ceil + 1

    source_id = options.fetch("source-id", nil)
    source_id = source_id.underscore if source_id.present?

    relation_type_id = options.fetch("relation-type-id", nil)
    relation_type_id = relation_type_id.underscore if relation_type_id.present?

    params = { page: page,
               per_page: options.fetch(:rows, 25),
               q: options.fetch(:query, nil),
               relation_type_id: relation_type_id,
               work_id: options.fetch("work-id", nil),
               work_ids: options.fetch("work-ids", nil),
               source_id: source_id }.compact
    url + "?" + URI.encode_www_form(params)
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    items = result.fetch("data", {}).fetch("relations", [])

    meta = result.fetch("data", {}).fetch("meta", {})
    meta = { total: meta["total"],
             sources: meta["sources"],
             publishers: meta["publishers"],
             relation_types: meta["relation_types"] }

    publisher_ids = Array(meta.fetch(:publishers, [])).map { |i| i["id"] }.join(",")
    publishers = Publisher.collect_data(ids: publisher_ids).fetch(:data, [])

    { data: parse_items(items, sources: cached_sources, publishers: publishers, relation_types: cached_relation_types), meta: meta }
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/relations"
  end
end
