require_relative 'agent'

class Orcid < Agent
  def name
    'orcid'
  end

  def title
    'DataCite (ORCID)'
  end

  def description
    'Push works with ORCID nameIdentifier.'
  end

  def source_id
    'datacite_orcid'
  end

  def q
    "nameIdentifier:ORCID\\:*"
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
