class Milestone < Base
  attr_reader :id, :title, :description, :open_issues, :closed_issues, :state, :due_on, :year, :quarter, :created_at, :updated_at, :closed_at

  def initialize(attributes, options={})
    @id = attributes.fetch("number", nil)
    @title = attributes.fetch("title", nil)
    @description = attributes.fetch("description", nil).presence
    @open_issues = attributes.fetch("open_issues", nil)
    @closed_issues = attributes.fetch("closed_issues", nil)
    @state = attributes.fetch("state", nil)
    @due_on = attributes.fetch("due_on", nil)
    @created_at = attributes.fetch("created_at", nil)
    @updated_at = attributes.fetch("updated_at", nil)
    @closed_at = attributes.fetch("closed_at", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{url}/#{options[:id]}"
    else
      url + "?state=all"
    end
  end

  def self.parse_data(result, options={})
    return nil if result.body.blank? || result.body['errors']

    if options[:id].present?
      item = result.body.fetch("data", {})
      return {} unless item.present?

      { data: parse_item(item) }
    else
      items = result.body.fetch("data", [])
      data = parse_items(items)
        .select { |m| m.due_on.present? }
        .sort_by { |m| m.due_on }
      data = data.select { |m| m.year == options[:year].to_i } if options[:year].present?

      { data: data, meta: { total: data.length } }
    end
  end

  def self.url
    "#{ENV["GITHUB_MILESTONES_URL"]}/milestones"
  end

  def is_closed?
    state == "closed"
  end

  def year
    return nil unless due_on.present?

    Time.parse(due_on).year
  end

  def quarter
    return nil unless due_on.present?

    (Time.parse(due_on).month / 3.to_f).ceil
  end

  def released_at
    is_closed? ? due_on : nil
  end
end
