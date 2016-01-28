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

  def cron_line
    "40 19 * * *"
  end

  def push_url
    ENV['ORCID_UPDATE_URL']
  end
end
