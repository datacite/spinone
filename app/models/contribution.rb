class Contribution < Base
  attr_reader :id, :doi, :author, :title, :container_title, :source_id, :contributor_role_id, :type, :published, :issued, :updated_at

  # include helper module for extracting identifier
  include Identifiable

  def initialize(attributes)
    orcid = orcid_from_url(attributes.fetch("subj_id"))
    doi = doi_from_url(attributes.fetch("obj_id"))
    @id = "#{orcid}:#{doi}"
    @doi = attributes.fetch("DOI")
    @author = attributes.fetch("author", nil)
    @title = attributes.fetch("title", nil)
    @container_title = attributes.fetch("container-title", nil)
    @source_id = attributes.fetch("source_id", nil)
    @contributor_role_id = attributes.fetch("contributor_role_id", nil)
    @published = attributes.fetch("published", nil)
    @issued = attributes.fetch("issued", nil)
    @updated_at = attributes.fetch("timestamp", nil)
    @type = DATACITE_TYPE_TRANSLATIONS[@resource_type_general]
  end

  def self.get_query_url(options={})
    page = options.fetch(:offset, 0).to_i > 0 ? options.fetch(:offset, 0) : 1
    params = { page: page,
               per_page: options.fetch(:rows, 25),
               contributor_id: options.fetch("contributor-id", nil) }.compact
    url + "?" + URI.encode_www_form(params)
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    items = result.fetch("data", {}).fetch("contributions", [])
    total = result.fetch("data", {}).fetch("meta", {}).fetch("total", nil)

    { data: parse_items(items), meta: { total: total } }
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/contributions"
  end
end
