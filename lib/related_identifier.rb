require 'nokogiri'
require 'base64'
require_relative 'agent'

class RelatedIdentifier < Agent
  def name
    'related_identifier'
  end

  def title
    'Related Identifier'
  end

  def description
    'Push works with relatedIdentifier.'
  end

  def get_query_url(options = {})
    offset = options[:offset].to_i
    rows = options[:rows] || job_batch_size
    from_date = options[:from_date] || (Time.now.to_date - 1.day).iso8601
    until_date = options[:until_date] || Time.now.to_date.iso8601

    updated = "updated:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
    params = { q: "relatedIdentifier:DOI\\:*",
               start: offset,
               rows: rows,
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,relatedIdentifier,xml,updated",
               fq: "#{updated} AND has_metadata:true AND is_active:true",
               wt: "json" }
    url +  URI.encode_www_form(params)
  end

  def get_works(items)
    Array(items).map do |item|
      doi = item.fetch("doi", nil)
      pid = doi_as_url(doi)
      year = item.fetch("publicationYear", nil).to_i
      type = item.fetch("resourceTypeGeneral", nil)
      type = DATACITE_TYPE_TRANSLATIONS[type] if type

      publisher_id = item.fetch("datacentre_symbol", nil)

      xml = Base64.decode64(item.fetch('xml', "PGhzaD48L2hzaD4=\n"))
      xml = Hash.from_xml(xml).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])
      authors = [authors] if authors.is_a?(Hash)

      related_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:DOI:.+/ }
      related_works = related_identifiers.map { |work| get_related_work(work) }

      { "pid" => pid,
        "DOI" => doi,
        "author" => get_hashed_authors(authors),
        "container-title" => nil,
        "title" => item.fetch("title", []).first,
        "issued" => { "date-parts" => [[year]] },
        "publisher_id" => publisher_id,
        "registration_agency" => "datacite",
        "tracked" => true,
        "type" => type,
        "related_works" => related_works }
    end
  end

  def get_related_work(work)
    relation_type, _related_identifier_type, related_identifier = work.split(':', 3)
    pid = doi_as_url(related_identifier.strip.upcase)

    { "pid" => pid,
      "source_id" => source_id,
      "relation_type_id" => relation_type.underscore }
  end

  def get_events(items)
    Array(items).map do |item|
      pid = doi_as_url(item.fetch("doi"))
      related_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:DOI:.+/ }

      { source_id: source_id,
        work_id: pid,
        total: related_identifiers.length }
    end
  end

  def timeout
    600
  end

  def job_batch_size
    200
  end

  def cron_line
    "40 17 * * *"
  end

  def uuid
    ENV['RELATED_IDENTIFIER_UUID']
  end

  def push_url
    ENV['RELATED_IDENTIFIER_URL']
  end

  def access_token
    ENV['RELATED_IDENTIFIER_TOKEN']
  end
end
