class DataCenter < Base
  attr_reader :id, :title, :other_names, :prefixes, :data_center_id, :member_id, :ids, :member, :year, :created, :updated

  # include helper module for caching infrequently changing resources
  include Cacheable

  def initialize(attributes, options={})
    @id = attributes.fetch("id").downcase
    @title = attributes.fetch("title", nil)
    @other_names = attributes.fetch("other_names", [])
    @prefixes = attributes.fetch("prefixes", [])
    @data_center_id = attributes.fetch("data_center_id", nil)
    @ids = attributes.fetch("ids", nil)
    @created = attributes.fetch("created", nil)
    @created = @created.to_time.utc.iso8601 if @created.present?
    @updated = attributes.fetch("updated", nil)
    @updated = @updated.to_time.utc.iso8601 if @updated.present?
    @year = attributes.fetch("created").year if @created.present?

    @member_id = @id.split('.', 2).first
    @member_id = @member_id.downcase if @member_id.present?

    # associations
    @member = Array(options[:members]).find { |s| s.id == @member_id }
  end

  def self.ds
    DB[:datacentre]
  end

  def self.get_query(options={})
    if options[:id].present?
      cached_data_center_response(options[:id])
    else
      if options[:query].present? ||
        options[:ids].present? ||
        options[:year].present? ||
        options.dig(:page, :size) != 25 ||
        options.dig(:page, :number) != 1

        query = ds.where{(is_active = true) & (allocator > 100)}
        query = query.where("name LIKE ? OR SYMBOL = ?", "%#{options[:query]}%", options[:query]) if options[:query].present?
        query = query.where(symbol: options[:ids].split(",")) if options[:ids].present?
        query = query.where('YEAR(created) = ?', options[:year]) if options[:year].present?

        if options["member-id"].present?
          member = cached_member_response(options["member-id"].upcase)
          query = query.where(allocator: member.fetch(:id))
        end

        page = (options.dig(:page, :number) || 1).to_i
        per_page = (options.dig(:page, :size) || 25).to_i
        offset = (page - 1) * per_page
        total = query.count
        total_pages = (total.to_f / per_page).ceil

        if options["member-id"].present?
          members = [{ symbol: member.fetch(:symbol),
             name: member.fetch(:name),
             count: total }]
        else
          allocators = query.group_and_count(:allocator).all.map { |a| { id: a[:allocator], count: a[:count] } }
          members = cached_members_response
          members = (allocators + members).group_by { |h| h[:id] }.map { |k,v| v.reduce(:merge) }.select { |h| h[:count].present? }
        end

        if options["year"].present?
          years = [{ id: options["year"],
                     title: options["year"],
                     count: total }]
        else
          years = query.group_and_count(Sequel.extract(:year, :created)).all
          years = years.map { |y| { id: y.values.first.to_s, title: y.values.first.to_s, count: y.values.last } }
                       .sort { |a, b| b.fetch(:id) <=> a.fetch(:id) }
        end

        data = query.limit(per_page).offset(offset).order(:name)

        meta = { "total" => total,
                 "total_pages" => total_pages,
                 "page" => page,
                 "members" => members,
                 "years" => years }

        { "data" => { "data-centers" => data, "meta" => meta } }
      elsif options["member-id"].present?
        page = (options.dig(:page, :number) || 1).to_i
        per_page = (options.dig(:page, :size) || 25).to_i
        total = query.count
        total_pages = (total.to_f / per_page).ceil

        data = cached_data_centers_by_member_response(options["member-id"], options)

        member = cached_member_response(options["member-id"].upcase)
        members = [{ symbol: member.fetch(:symbol),
                     name: member.fetch(:name),
                     count: query.where(allocator: member.fetch(:id)).count }]

        years = cached_years_by_member_response(options["member-id"], options)
        meta = { "total" => total,
                 "total_pages" => total_pages,
                 "page" => page,
                 "members" => members,
                 "years" => years }
        { "data" => { "data-centers" => data, "meta" => meta } }
      else
        page = (options.dig(:page, :number) || 1).to_i
        per_page = (options.dig(:page, :size) || 25).to_i
        total = cached_total_response
        total_pages = (total.to_f / per_page).ceil

        data = cached_data_centers_response

        members = cached_allocators_response
        years = cached_years_response
        meta = { "total" => total,
                 "total_pages" => total_pages,
                 "page" => page,
                 "members" => members,
                 "years" => years }
        { "data" => { "data-centers" => data, "meta" => meta } }
      end
    end
  rescue StandardError => e
    Rails.logger.error e

    { "data" => {} }
  end

  def self.get_data(options={})
    get_query(options)
  end

  def self.parse_data(result, options={})
    return nil if result.blank?

    if options[:id]
      item = result.fetch("data", {}).fetch("data-center", {})
      return nil if item.blank?

      item = { "id" => item[:symbol], "title" => item[:name], "created" => item[:created], "updated" => item[:updated] }

      { data: parse_item(item, members: cached_members) }
    else
      items = result.fetch("data", {}).fetch("data-centers", []).map { |i| { "id" => i[:symbol], "title" => i[:name], "created" => i[:created], "updated" => i[:updated]} }
      meta = result.fetch("data", {}).fetch("meta", {})

      page = (options.dig(:page, :number) || 1).to_i
      per_page = (options.dig(:page, :size) || 25).to_i
      total = meta.fetch("total", 0)
      total_pages = (total.to_f / per_page).ceil

      members = meta.fetch("members", [])
                    .sort { |a, b| b.fetch(:count) <=> a.fetch(:count) }
                    .map do |i|
                           member = cached_members.find { |m| m.id == i.fetch(:symbol, nil) } || OpenStruct.new(title: i.fetch(:name, nil))
                           { id: i.fetch(:symbol).downcase, title: member.title, count: i.fetch(:count) }
                         end

      meta = { total: total,
               total_pages: total_pages,
               page: page,
               members: members,
               years: meta.fetch("years", []) }

      { data: parse_items(items, members: cached_members), meta: meta }
    end
  end
end
