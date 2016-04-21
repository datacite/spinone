require 'nokogiri'
require 'base64'
require_relative 'agent'

class RelatedIdentifier < Agent
  def name
    'related_identifier'
  end

  def title
    'DataCite (RelatedIdentifier)'
  end

  def description
    'Push works with relatedIdentifier.'
  end

  def source_id
    'datacite_related'
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
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,relatedIdentifier,xml,minted,updated",
               fq: "#{updated} AND has_metadata:true AND is_active:true",
               wt: "json" }
    url +  URI.encode_www_form(params)
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
               "registration_agency" => "datacite",
               "tracked" => true,
               "type" => type }

      related_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:DOI:10\..+/ }
      sum += get_relations(subj, related_identifiers)
    end
  end

  def get_relations(subj, items)
    prefix = subj["DOI"][/^10\.\d{4,5}/]

    Array(items).map do |item|
      raw_relation_type, _related_identifier_type, related_identifier = item.split(':', 3)
      doi = related_identifier.strip.upcase

      registration_agency = get_doi_ra(doi)

      _source_id = registration_agency == "crossref" ? "datacite_crossref" : "datacite_related"

      { prefix: prefix,
        relation: { "subj_id" => subj["pid"],
                    "obj_id" => doi_as_url(doi),
                    "relation_type_id" => raw_relation_type.underscore,
                    "source_id" => _source_id,
                    "publisher_id" => subj["publisher_id"] },
        subj: subj }
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
