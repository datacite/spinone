require_relative 'agent'

class OrcidUpdate < Agent
  def name
    'orcid_update'
  end

  def title
    'ORCID Auto-Update'
  end

  def description
    'Push works with ORCID nameIdentifier to ORCID.'
  end

  def source_id
    'orcid_update'
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

  def get_contributors(items)
    Array(items).reduce([]) do |sum, item|
      orcids = item.fetch('nameIdentifier', [])
        .select { |id| id =~ /^ORCID:0000.+/ }
        .map { |i| i.split(':', 2).last }
      orcids.reduce(sum) do |sum, orcid|
        sum + [{ "uid" => "http://orcid.org/#{orcid}",
                 "related_works" => {
                   "pid" => "http://doi.org/#{item['doi']}",
                   "source_id" => source_id }}]
      end
    end
  end

  def job_batch_size
    1000
  end

  def cron_line
    "40 19 * * *"
  end

  def uuid
    ENV['ORCID_UPDATE_UUID']
  end

  def push_url
    ENV['ORCID_UPDATE_URL']
  end

  def access_token
    ENV['ORCID_UPDATE_TOKEN']
  end
end
