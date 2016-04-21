require_relative 'agent'

class Github < Agent
  def name
    'github'
  end

  def title
    'DataCite (GitHub)'
  end

  def description
    'Push works with Github relatedIdentifier.'
  end

  def source_id
    'datacite_github'
  end

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.now.to_date.iso8601

    updated = "updated:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
    params = { q: "relatedIdentifier:URL\\:https\\:\\/\\/github.com*",
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

      related_identifiers = item.fetch('relatedIdentifier', []).select { |id| id =~ /:URL:https:\/\/github.com.+/ }
      sum += get_relations(subj, related_identifiers)
    end
  end

  def get_relations(subj, items)
    prefix = subj["DOI"][/^10\.\d{4,5}/]

    Array(items).reduce([]) do |sum, item|
      raw_relation_type, _related_identifier_type, related_identifier = item.split(':', 3)

      # find relation_type, default to "is_referenced_by" otherwise
      relation_type = cached_relation_type(raw_relation_type.underscore)
      relation_type_id = relation_type.present? ? relation_type.name : 'is_referenced_by'

      # get parent repo
      # code from https://github.com/octokit/octokit.rb/blob/master/lib/octokit/repository.rb
      related_identifier = PostRank::URI.clean(related_identifier)
      github_hash = github_from_url(related_identifier)
      owner_url = github_as_owner_url(github_hash)
      repo_url = github_as_repo_url(github_hash)

      sum << { prefix: prefix,
               relation: { "subj_id" => subj["pid"],
                           "obj_id" => related_identifier,
                           "relation_type_id" => relation_type_id,
                           "source_id" => source_id,
                           "publisher_id" => subj["publisher_id"] },
               subj: subj }

      sum << { relation: { "subj_id" => related_identifier,
                           "obj_id" => repo_url,
                           "relation_type_id" => "is_part_of",
                           "source_id" => source_id,
                           "publisher_id" => "github" } }

      sum << {  message_type: "contribution",
                relation: { "subj_id" => owner_url,
                            "obj_id" => repo_url,
                            "source_id" => "github_contributor" }}
    end
  end

  def job_batch_size
    1000
  end

  def cron_line
    "40 18 * * *"
  end

  def uuid
    ENV['GITHUB_UUID']
  end

  def push_url
    ENV['GITHUB_URL']
  end

  def access_token
    ENV['GITHUB_TOKEN']
  end
end
