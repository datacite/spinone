class UserStory < Base
  attr_reader :id, :url, :title, :description, :state, :milestone, :comments, :projects, :stakeholders, :inactive, :created, :updated, :closed

  LABEL_COLORS = {
    "project" => "006b75",
    "stakeholder" => "f9cfb9",
    "state" => "ededed",
    "inactive" => "c8d1da"
  }
  def initialize(attributes, options={})
    @id = attributes.fetch("number", nil)
    @title = attributes.fetch("title", nil)
    @description = GitHub::Markdown.render_gfm(attributes.fetch("body", nil))
    state = attributes.fetch("state", nil) == "closed" ? "done" : "inbox"
    @comments = attributes.fetch("comments", nil)
    labels = Array.wrap(attributes.fetch("labels", nil))
      .select { |l| l["name"] != "user story" }
    @projects = labels
      .select { |l| l["color"] == LABEL_COLORS["project"] }
      .map { |l| l["name"] }
    @stakeholders = labels
      .select { |l| l["color"] == LABEL_COLORS["stakeholder"] }
      .map { |l| l["name"] }
    @state = labels
      .select { |l| l["color"] == LABEL_COLORS["state"] }
      .map { |l| l["name"] }.first || state
    @inactive = labels
      .select { |l| l["color"] == LABEL_COLORS["inactive"] }
      .map { |l| l["name"] }
    @milestone = attributes.dig("milestone", "title")
    @created = attributes.fetch("created_at", nil)
    @updated = attributes.fetch("updated_at", nil)
    @closed = attributes.fetch("closed_at", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      "#{ENV["GITHUB_MILESTONES_URL"]}/issues/#{options[:id]}?github_token=#{ENV['GITHUB_PERSONAL_ACCESS_TOKEN']}"
    else
      label = ["user story", options[:project], options[:stakeholder]].compact
        .map { |l| "label:\"#{l}\"" }.join(" ")
      milestone = [options[:milestone]].compact
        .map { |m| "milestone:\"#{m}\"" }.first

      if options[:state] == "done"
        state = "state:closed"
      elsif options[:state] == "open"
          state = "state:open"
      elsif options[:state] == "inbox"
        state = "state:open -label:discussion -label:planning -label:ready -label:\"in progress\" -label:\"needs review\""
      else
        state = [options[:state]].compact
          .map { |m| "label:\"#{m}\"" }.first
      end

      params = { q: ["repo:datacite/datacite", label, milestone, state, options[:query]].compact.join(" "),
                 page: options[:page] || 1,
                 per_page: options[:per_page] || 100,
                 sort: "created",
                 order: "desc",
                 github_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN'] }.compact

      url + "?" + URI.encode_www_form(params)
    end
  end

  def self.get_total(options={})
    query_url = get_query_url(options.merge(per_page: 0))
    result = Maremma.get(query_url, options)
    result.body.dig("data", "total_count").to_i
  end

  def self.get_data(options={})
    if options[:id].present?
      query_url = get_query_url(options)
      Maremma.get(query_url, options)
    else
      total = get_total(options)
      data = []

      if total > 0
        # walk through paginated results
        total_pages = (total.to_f / 100).ceil

        (1..total_pages).each do |page|
          options[:page][:number] = page
          query_url = get_query_url(options)
          result = Maremma.get(query_url, options)
          data += (result.body.dig("data", "items") || [])
        end
      end

      { data: data, total: total }
    end
  end

  def self.parse_data(result, options={})
    return nil if result.blank? || result['errors']

    if options[:id].present?
      item = result.body.fetch("data", {})
      return {} unless item.present?

      { data: parse_item(item) }
    else
      data = parse_items(result.fetch(:data, []))
      meta = { total: result[:total],
               projects: parse_meta(data, "projects"),
               milestones: parse_meta(data, "milestone"),
               stakeholders: parse_meta(data, "stakeholders"),
               state: parse_meta(data, "state") }

      page = (options.dig(:page, :number) || 1).to_i
      per_page = (options.dig(:page, :size) || 25).to_i
      offset = (page - 1) * per_page
      data = data[offset...offset + per_page] || []

      { data: data, meta: meta }
    end
  end

  def self.parse_meta(items, label)
    it = items.reduce({}) do |sum, i|
      Array.wrap(i.send(label)).each { |tag| sum[tag] = sum[tag].to_i + 1 }
      sum
    end

    if label == "state"
      { "inbox" => it["inbox"].to_i,
        "discussion" => it["discussion"].to_i,
        "planning" => it["planning"].to_i,
        "ready" => it["ready"].to_i,
        "needs review" => it["needs review"].to_i,
        "done" => it["done"].to_i }.select { |k,v| v > 0 }
    else
      it.sort_by {|_key, value| -value}[0..10].to_h
    end
  end

  def url
    "#{ENV["GITHUB_ISSUES_REPO_URL"]}/issues/#{id}"
  end

  def self.url
    "https://api.github.com/search/issues"
  end

  def is_closed?
    state == "closed"
  end
end
