class Person < Base
  attr_reader :id, :given, :family, :literal, :orcid, :github, :updated_at

  # include helper module for extracting identifier
  include Identifiable

  def initialize(item, options={})
    attributes = item.fetch('attributes', {})
    @id = item.fetch("id", nil)
    @given = attributes.fetch("given-names", nil)
    @family = attributes.fetch("family-name", nil)
    @literal = attributes.fetch("credit-name", nil)
    unless @literal.present? || @given.present? || @family.present?
      @literal = orcid_from_url(@id)
    end
    @orcid = attributes.fetch("orcid", nil)
    @github = attributes.fetch("github", nil)
    @updated_at = attributes.fetch("updated", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      offset = options.fetch(:offset, 0).to_f
      page = (offset / 25).ceil + 1

      params = { "page[number]" => page,
                 "page[size]" => options.fetch(:rows, 25),
                 query: options.fetch(:query, nil) }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    return nil if result.blank? || result['errors']

    if options[:id].present?
      item = result.fetch("data", {})
      return {} unless item.present?

      { data: parse_item(item) }
    else
      items = result.fetch("data", [])
      meta = result.fetch("meta", {}).except("total-pages", "page")

      { data: parse_items(items), meta: meta }
    end
  end

  def self.url
    "#{ENV["VOLPINO_URL"]}/users"
  end
end
