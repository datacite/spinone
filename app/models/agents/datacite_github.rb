class DataciteGithub < Agent
  # include common methods for DataCite
  include Datacitable

  def q
    "relatedIdentifier:URL\\:https\\:\\/\\/github.com*"
  end

  def rate_limiting
    config.rate_limiting || 5000
  end

  def timeout
    config.timeout || 600
  end

  def config_fields
    [:url, :push_url, :access_token, :personal_access_token]
  end

  def personal_access_token
    ENV['GITHUB_PERSONAL_ACCESS_TOKEN']
  end
end
