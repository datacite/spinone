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

  def q
    "relatedIdentifier:URL\\:https\\:\\/\\/github.com*"
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
