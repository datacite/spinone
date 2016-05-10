class Event < Base
  attr_reader :id, :state, :message_type, :message_action, :source_token, :prefix, :subj_id, :obj_id, :subj, :obj, :source_id, :relation_type_id, :registration_agency_id, :total, :occurred_at, :updated_at

  def initialize(attributes)
    @id = attributes.fetch("id", nil)
    @state = attributes.fetch("state", nil)
    @message_type = attributes.fetch("message_type", nil)
    @message_action = attributes.fetch("message_action", nil)
    @source_token = attributes.fetch("source_token", nil)
    @prefix = attributes.fetch("prefix", nil)
    @subj_id = attributes.fetch("subj_id", nil)
    @obj_id = attributes.fetch("obj_id", nil)
    @subj = attributes.fetch("subj", nil)
    @obj = attributes.fetch("obj", nil)
    @source_id = attributes.fetch("source_id", nil)
    @relation_type_id = attributes.fetch("relation_type_id", nil)
    @registration_agency_id = attributes.fetch("registration_agency_id", nil)
    @total = attributes.fetch("toal", 1)
    @occurred_at = attributes.fetch("occurred_at", nil)
    @updated_at = attributes.fetch("timestamp", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      params = { page: options.fetch(:offset, 1),
                 per_page: options.fetch(:rows, 25),
                 q: options.fetch(:q, nil),
                 state: options.fetch(:state, nil),
                 prefix: options.fetch(:prefix, nil),
                 message_type: options.fetch(:message_type, nil),
                 source_token: options.fetch(:source_token, nil),
                 source_id: options.fetch(:source_id, nil),
                 registration_agency_id: options.fetch(:registration_agency_id, nil) }.compact
      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.parse_data(result, options={})
    return result if result['errors']

    if options[:id]
      item = result.fetch("data", {}).fetch("deposit", {})
      return nil if item.blank?

      { data: parse_item(item) }
    else
      items = result.fetch("data", {}).fetch("deposits", [])
      total = result.fetch("data", {}).fetch("meta", {}).fetch("total", nil)

      { data: parse_items(items), meta: { total: total } }
    end
  end

  def self.parse_item(item)
    self.new(item)
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/deposits"
  end
end
