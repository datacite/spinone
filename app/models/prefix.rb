class Prefix < Base
  attr_reader :id, :registration_agency, :updated_at

  RA_HANDLES = {
    "10.SERV/CROSSREF" => "Crossref",
    "10.SERV/DEFAULT"=> "Crossref",
    "10.SERV/DATACITE" => "DataCite",
    "10.SERV/ETH" => "DataCite",
    "10.SERV/EIDR" => "EIDR",
    "10.SERV/KISTI" => "KISTI",
    "10.SERV/MEDRA" => "mEDRA",
    "10.SERV/ISTIC" => "ISTIC",
    "10.SERV/JALC" => "JaLC",
    "10.SERV/AIRITI" => "Airiti",
    "10.SERV/CNKI" => "CNKI",
    "10.SERV/OP" => "OP"
  }

  def initialize(attributes, options={})
    @id = attributes.fetch("id").underscore.dasherize
    @registration_agency = attributes.fetch("registration_agency", nil)
    @updated_at = attributes.fetch("updated_at", nil)
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
      response_code = result.dig("data", "responseCode")
      return nil unless response_code == 1

      record = result.fetch("data", {}).fetch("values", []).find { |hs| hs["type"] == "HS_SERV" }
      ra = record.dig("data", "value")

      item = {
        "id" => result.dig("data", "handle"),
        "registration_agency" => RA_HANDLES[ra] || ra,
        "updated_at" => record.fetch("timestamp", nil) }

      { data: parse_item(item) }
    end
  end

  def self.url
    "https://doi.org/api/handles"
  end
end
