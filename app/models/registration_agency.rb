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

  def get_data(options={})
    [{ "id" => "crossref",
       "title" => "Crossref",
       "timestamp" => "2016-04-27T02:23:01Z"
     },
     { "id" => "datacite",
       "title" => "DataCite",
       "timestamp" => "2016-04-27T02:23:01Z"
    }]
  end

  def self.parse_data(items, options={})
    if options[:id]
      item = items.find { |i| i["id"] == options[:id] }
      return nil if item.nil?

      { data: parse_item(item) }
    else
      { data: parse_items(items), meta: { total: items.length } }
    end
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/registration_agencies"
  end
end
