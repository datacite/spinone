class Contribution < Base
  attr_reader :id, :subj_id, :obj_id, :orcid, :github, :credit_name, :doi, :url, :author, :title, :container_title, :contributor_role_id, :work_type_id, :source_id, :publisher_id, :source, :publisher, :published, :issued, :updated_at

  # include helper module for extracting identifier
  include Identifiable

  # include helper module for caching infrequently changing resources
  include Cacheable

  def initialize(attributes, options={})
    @id = SecureRandom.uuid
    @subj_id = attributes.fetch("subj_id")
    @obj_id = attributes.fetch("obj_id")

    @orcid = orcid_from_url(attributes.fetch("subj_id"))
    @github = github_owner_from_url(attributes.fetch("subj_id"))

    @credit_name = attributes.fetch("credit_name", nil)

    @doi = attributes.fetch("DOI", nil)
    @url = attributes.fetch("URL", nil)
    @author = attributes.fetch("author", nil)
    @title = attributes.fetch("title", nil)
    @container_title = attributes.fetch("container-title", nil)
    @contributor_role_id = attributes.fetch("contributor_role_id", nil)
    @contributor_role_id = @contributor_role_id.underscore.dasherize if @contributor_role_id.present?
    @published = attributes.fetch("published", nil)
    @issued = attributes.fetch("issued", nil)
    @updated_at = attributes.fetch("timestamp", nil)
    @work_type_id = attributes.fetch("work_type_id", nil).presence || DATACITE_TYPE_TRANSLATIONS[attributes["resourceTypeGeneral"]] || "work"
    @work_type_id = @work_type_id.underscore.dasherize if @work_type_id.present?

    @publisher_id = attributes.fetch("publisher_id", nil)
    @publisher_id = @publisher_id.underscore.dasherize if @publisher_id.present?
    @source_id = attributes.fetch("source_id", nil)
    @source_id = @source_id.underscore.dasherize if @source_id.present?

    # associations
    @publisher = Array(options[:publishers]).find { |p| p.id == @publisher_id  }
    @source = Array(options[:sources]).find { |p| p.id == @source_id  }
  end

  def self.get_query_url(options={})
    offset = options.fetch(:offset, 0).to_f
    page = (offset / 25).ceil + 1

    source_id = options.fetch("source-id", nil)
    source_id = source_id.underscore if source_id.present?

    params = { page: page,
               per_page: options.fetch(:rows, 25),
               contributor_id: options.fetch("contributor-id", nil),
               work_id: options.fetch("work-id", nil),
               publisher_id: options.fetch("publisher-id", nil),
               source_id: source_id }.compact
    url + "?" + URI.encode_www_form(params)
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    items = result.fetch("data", {}).fetch("contributions", [])
    meta = result.fetch("data", {}).fetch("meta", {})
    meta = { total: meta["total"],
             sources: meta["sources"],
             publishers: meta["publishers"]
           }

    publisher_ids = meta.fetch(:publishers, []).map { |i| i["id"] }.join(",")
    publishers = Publisher.collect_data(ids: publisher_ids).fetch(:data, [])

    { data: parse_items(items, sources: cached_sources, publishers: publishers), meta: meta}
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/contributions"
  end
end
