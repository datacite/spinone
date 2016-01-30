require_relative 'agent'

class OrcidUpdate < Orcid
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

  def get_works(items)
    []
  end

  def get_events(items)
    []
  end

  def cron_line
    "40 19 * * *"
  end

  def push_url
    ENV['ORCID_UPDATE_URL']
  end

  def access_token
    ENV['ORCID_UPDATE_TOKEN']
  end
end
