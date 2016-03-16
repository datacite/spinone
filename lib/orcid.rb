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

  def source_id
    'datacite_orcid'
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
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre_symbol,nameIdentifier,xml,updated",
               fq: "#{updated} AND has_metadata:true AND is_active:true",
               wt: "json" }
    url + URI.encode_www_form(params)
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
               "issued" => item.fetch("publicationYear", nil),
               "publisher_id" => publisher_id,
               "registration_agency" => "datacite",
               "tracked" => true,
               "type" => type }

      name_identifiers = item.fetch('nameIdentifier', []).select { |id| id =~ /^ORCID:.+/ }
      sum += get_relations(subj, name_identifiers)
    end
  end

  def get_relations(subj, items)
    prefix = subj["DOI"][/^10\.\d{4,5}/]

    Array(items).map do |item|
      orcid = item.split(':', 2).last

      { prefix: prefix,
        message_type: "contribution",
        relation: { "subj_id" => subj["pid"],
                    "obj_id" => "http://orcid.org/#{orcid}",
                    "source_id" => source_id,
                    "publisher_id" => subj["publisher_id"] },
        subj: subj }
    end
  end

  def get_contributor(work)
    orcid = work.split(':', 2).last
    pid = "http://orcid.org/#{orcid}"

    { "pid" => pid,
      "source_id" => source_id }
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
