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

  def get_query_url(offset: 0, rows: job_batch_size, from_date: (Time.now.to_date - 1.day).iso8601, until_date: Time.now.to_date.iso8601)
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
      name_identifiers = item.fetch('nameIdentifier', []).select { |id| id =~ /^ORCID:.+/ }
      name_identifiers.map { |work| { orcid: work.split(':', 2).last, doi: doi }}
    end
  end

  def job_batch_size
    1000
  end
end
