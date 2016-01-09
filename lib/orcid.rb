require_relative 'agent'

class Orcid < Agent
  def name
    'orcid'
  end

  def title
    'ORCID'
  end

  def description
    'Push works with ORCID nameIdentifier.'
  end

  def get_query_url(options = {})
    offset = options[:offset].to_i
    rows = options[:rows] || job_batch_size
    from_date = options[:from_date] || (Time.now.to_date - 1.day).iso8601
    until_date = options[:until_date] || Time.now.to_date.iso8601

    updated = "updated:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
    params = { q: "nameIdentifier:ORCID\\:*",
               start: offset,
               rows: rows,
               fl: "doi,nameIdentifier,updated",
               fq: "#{updated} AND has_metadata:true AND is_active:true",
               wt: "json" }
    url + URI.encode_www_form(params)
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

      name_identifiers = item.fetch('nameIdentifier', []).select { |id| id =~ /^ORCID:.+/ }
      contributors = name_identifiers.map { |work| get_contributor(work) }

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
        "contributors" => contributors }
    end
  end

  def get_contributor(work)
    orcid = work.split(':', 2).last
    pid = "http://orcid.org/#{orcid}"

    { "pid" => pid,
      "source_id" => source_id }
  end

  def get_events(items)
    Array(items).map do |item|
      pid = doi_as_url(item.fetch("doi"))
      name_identifiers = item.fetch('nameIdentifier', []).select { |id| id =~ /^ORCID:.+/ }.map { |id| { 'nameIdentifier' => id }}

      { source_id: source_id,
        work_id: pid,
        total: name_identifiers.length,
        extra: name_identifiers }
    end
  end

  def job_batch_size
    1000
  end

  def cron_line
    "40 18 * * *"
  end

  def uuid
    ENV['ORCID_UUID']
  end

  def push_url
    ENV['ORCID_URL']
  end

  def access_token
    ENV['ORCID_TOKEN']
  end
end
