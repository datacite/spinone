require 'nokogiri'
require 'base64'
require_relative 'agent'

class RelatedIdentifier < Agent
  def name
    'related_identifier'
  end

  def title
    'DataCite (RelatedIdentifier)'
  end

  def description
    'Push works with relatedIdentifier.'
  end

  def source_id
    'datacite_related'
  end

  def q
    "relatedIdentifier:DOI\\:*"
  end

  def timeout
    600
  end

  def job_batch_size
    200
  end

  def cron_line
    "40 17 * * *"
  end

  def uuid
    ENV['RELATED_IDENTIFIER_UUID']
  end

  def push_url
    ENV['RELATED_IDENTIFIER_URL']
  end

  def access_token
    ENV['RELATED_IDENTIFIER_TOKEN']
  end
end
