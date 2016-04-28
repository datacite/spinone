require 'sinatra/base'
require 'json'
require 'maremma'
require 'postrank-uri'
require 'parse-cron'
require_relative 'formatting'
require_relative 'redis_client'
require_relative 'metadata'

class Agent
  include Sinatra::Formatting
  include Sinatra::RedisClient
  include Sinatra::Metadata

  def self.all
    Agent.descendants.map { |a| a.new }.sort_by { |agent| agent.name }
  end

  def self.find_by_uuid(param)
    all.find { |agent| agent.uuid == param }
  end

  def process_data(options)
    result = get_data(options)
    result = parse_data(result)
    push_data(result)
  end

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.now.to_date.iso8601

    updated = "updated:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
    fq = "#{updated} AND has_metadata:true AND is_active:true"

    params = { q: q,
               start: offset,
               rows: rows,
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,relatedIdentifier,nameIdentifier,xml,minted,updated",
               fq: fq,
               wt: "json" }
    url +  URI.encode_www_form(params)
  end

  def queue_jobs(options={})
    total = get_total(options)

    unless options[:all]
      return 0 unless stale?
    end

    if total > 0
      # walk through paginated results
      total_pages = (total.to_f / job_batch_size).ceil

      (0...total_pages).each do |page|
        options[:offset] = page * job_batch_size
        AgentJob.perform_async(name, options)
      end
    end

    scheduled_at = Time.now if total > 0

    # return number of works or contributors queued
    total
  end

  def get_total(options={})
    query_url = get_query_url(options.merge(rows: 0))
    result = Maremma.get(query_url, options)
    result.fetch("data", {}).fetch("response", {}).fetch("numFound", 0)
  end

  def get_data(options={})
    query_url = get_query_url(options)
    Maremma.get(query_url, options)
  end

  def parse_data(result)
    return result if result["errors"]

    items = result.fetch("data", {}).fetch('response', {}).fetch('docs', nil)
    get_relations_with_related_works(items)
  end

  def get_relations_with_related_works(items)
    Array(items).reduce([]) do |sum, item|
      doi = item.fetch("doi", nil)
      pid = doi_as_url(doi)
      type = item.fetch("resourceTypeGeneral", nil)
      type = DATACITE_TYPE_TRANSLATIONS[type] if type
      publisher_id = item.fetch("datacentre_symbol", nil)

      xml = Base64.decode64(item.fetch('xml', "PGhzaD48L2hzaD4=\n"))
      xml = Hash.from_xml(xml).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])
      authors = [authors] if authors.is_a?(Hash)

      subj = { "pid" => pid,
               "DOI" => doi,
               "author" => get_hashed_authors(authors),
               "title" => item.fetch("title", []).first,
               "container-title" => item.fetch("publisher", nil),
               "published" => item.fetch("publicationYear", nil),
               "issued" => item.fetch("minted", nil),
               "publisher_id" => publisher_id,
               "registration_agency_id" => "datacite",
               "tracked" => true,
               "type" => type }

      related_doi_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:DOI:.+/ }
      sum += get_doi_relations(subj, related_doi_identifiers)

      related_github_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:URL:https:\/\/github.com.+/ }
      sum += get_github_relations(subj, related_github_identifiers)

      name_identifiers = item.fetch('nameIdentifier', []).select { |id| id =~ /^ORCID:.+/ }
      sum += get_contributions(subj, name_identifiers)
    end
  end

  def get_github_relations(subj, items)
    prefix = subj["DOI"][/^10\.\d{4,5}/]

    Array(items).reduce([]) do |sum, item|
      raw_relation_type, _related_identifier_type, related_identifier = item.split(':', 3)

      # get parent repo
      # code from https://github.com/octokit/octokit.rb/blob/master/lib/octokit/repository.rb
      related_identifier = PostRank::URI.clean(related_identifier)
      github_hash = github_from_url(related_identifier)
      owner_url = github_as_owner_url(github_hash)
      repo_url = github_as_repo_url(github_hash)

      sum << { prefix: prefix,
               relation: { "subj_id" => subj["pid"],
                           "obj_id" => related_identifier,
                           "relation_type_id" => raw_relation_type.underscore,
                           "source_id" => source_id,
                           "publisher_id" => subj["publisher_id"],
                           "registration_agency_id" => "github",
                           "occurred_at" => subj["issued"] },
               subj: subj }

      # if relatedIdentifier is release URL rather than repo URL
      if related_identifier != repo_url
        sum << { relation: { "subj_id" => related_identifier,
                             "obj_id" => repo_url,
                             "relation_type_id" => "is_part_of",
                             "source_id" => source_id,
                             "publisher_id" => "github",
                             "registration_agency_id" => "github" } }
      end

      sum << {  message_type: "contribution",
                relation: { "subj_id" => owner_url,
                            "obj_id" => repo_url,
                            "source_id" => "github_contributor",
                            "registration_agency_id" => "github" }}
    end
  end

  def get_doi_relations(subj, items)
    prefix = subj["DOI"][/^10\.\d{4,5}/]

    Array(items).reduce([]) do |sum, item|
      raw_relation_type, _related_identifier_type, related_identifier = item.split(':', 3)
      doi = related_identifier.strip.upcase
      registration_agency = get_doi_ra(doi)

      _source_id = registration_agency == "crossref" ? "datacite_crossref" : "datacite_related"
      pid = doi_as_url(doi)

      sum << { prefix: prefix,
               relation: { "subj_id" => subj["pid"],
                           "obj_id" => pid,
                           "relation_type_id" => raw_relation_type.underscore,
                           "source_id" => _source_id,
                           "publisher_id" => subj["publisher_id"],
                           "registration_agency_id" => registration_agency,
                           "occurred_at" => subj["issued"] },
               subj: subj }
    end
  end

  # we are flipping subj and obj for contributions
  def get_contributions(obj, items)
    prefix = obj["DOI"][/^10\.\d{4,5}/]

    Array(items).reduce([]) do |sum, item|
      orcid = item.split(':', 2).last
      orcid = validated_orcid(item.split(':', 2).last)

      return sum if orcid.nil?

      sum << { prefix: prefix,
               message_type: "contribution",
               relation: { "subj_id" => orcid_as_url(orcid),
                           "obj_id" => obj["pid"],
                           "source_id" => source_id,
                           "publisher_id" => obj["publisher_id"],
                           "registration_agency_id" => "datacite",
                           "occurred_at" => obj["issued"] },
               obj: obj }
    end
  end

  # push to deposit API if no error and we have collected works
  def push_data(items)
    return [] if items.empty?

    callback = "#{ENV['SERVER_URL']}/api/agents"

    Array(items).map do |item|
      relation = item.fetch(:relation, {})
      deposit = { "deposit" => { "subj_id" => relation.fetch("subj_id", nil),
                                 "obj_id" => relation.fetch("obj_id", nil),
                                 "relation_type_id" => relation.fetch("relation_type_id", nil),
                                 "source_id" => relation.fetch("source_id", nil),
                                 "publisher_id" => relation.fetch("publisher_id", nil),
                                 "subj" => item.fetch(:subj, {}),
                                 "obj" => item.fetch(:obj, {}),
                                 "message_type" => item.fetch(:message_type, "relation"),
                                 "prefix" => item.fetch(:prefix, nil),
                                 "source_token" => uuid,
                                 "callback" => callback } }

      Maremma.post push_url, data: deposit, token: access_token
    end
  end

  def url
    "http://search.datacite.org/api?"
  end

  def update_count(message_size)
    self.count += message_size.to_i
  end

  def timestamp_key
    "#{name}:timestamp"
  end

  def count_key
    "#{name}:count"
  end

  def scheduled_at
    redis.get timestamp_key || Time.now.iso8601
  end

  def scheduled_at=(timestamp)
    cron_parser = CronParser.new(cron_line)
    time = cron_parser.next(Time.iso8601(timestamp))
    redis.set timestamp_key, time.iso8601
  end

  def count
    (redis.get count_key).to_i
  end

  def count=(number)
    redis.set count_key, number.to_s
  end

  def stale?
    scheduled_at.to_s <= Time.now.iso8601
  end
end
