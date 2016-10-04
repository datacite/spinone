class Contributor < Base
  attr_reader :id, :given, :family, :literal, :orcid, :github, :updated_at

  # include helper module for extracting identifier
  include Identifiable

  def initialize(attributes, options={})
    @id = attributes.fetch("id", nil)
    @given = attributes.fetch("given", nil)
    @family = attributes.fetch("family", nil)
    @literal = attributes.fetch("literal", nil)
    unless @literal.present? || @given.present? || @family.present?
      @literal = github_owner_from_url(@id).presence || orcid_from_url(@id)
    end
    @orcid = orcid_from_url(@id)
    @github = github_owner_from_url(@id)
    @updated_at = attributes.fetch("timestamp", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      id = options[:id] # || "https://github.com/#{options[:id]}"
      "#{url}/#{id}"
    else
      offset = options.fetch(:offset, 0).to_f
      page = (offset / 25).ceil + 1

      params = { page: page,
                 per_page: options.fetch(:rows, 25),
                 q: options.fetch(:query, nil) }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    return nil if result.blank? || result['errors']

    if options[:id]
      item = result.fetch("data", {}).fetch("contributor", {})
      return nil if item.blank?

      { data: parse_item(item) }
    else
      items = result.fetch("data", {}).fetch("contributors", [])
      total = result.fetch("data", {}).fetch("meta", {}).fetch("total", nil)

      { data: parse_items(items), meta: { total: total } }
    end
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/contributors"
  end
end
