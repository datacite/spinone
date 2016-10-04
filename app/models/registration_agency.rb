class RegistrationAgency < Base
  attr_reader :id, :title, :updated_at

  def initialize(attributes, options={})
    @id = attributes.fetch("id", nil)
    @title = attributes.fetch("title", nil)
    @updated_at = attributes.fetch("timestamp", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      url
    end
  end

  def self.parse_data(result, options={})
    return nil if result.blank? || result['errors']

    if options[:id]
      item = result.fetch("data", {}).fetch("registration_agency", {})
      return nil if item.blank?

      { data: parse_item(item) }
    else
      items = result.fetch("data", {}).fetch("registration_agencies", [])
      total = result.fetch("data", {}).fetch("meta", {}).fetch("total", nil)

      { data: parse_items(items), meta: { total: total } }
    end
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/registration_agencies"
  end
end
