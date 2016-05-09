class OrcidUpdate < Agent
  # include common methods for DataCite
  include Datacitable

  def q
    "nameIdentifier:ORCID\\:*"
  end

  def cron_line
    config.cron_line || "40 20 * * *"
  end

  def push_url
    "#{ENV['VOLPINO_URL']}/claims"
  end

  def access_token
    ENV['VOLPINO_TOKEN']
  end

  # push to Volpino API if no error and we have collected works
  def push_data(items)
    return [] if items.empty?

    callback = "#{ENV['SERVER_URL']}/api/agents"

    Array(items).map do |item|
      relation = item.fetch(:relation, {})
      claim = { "claim" => { "orcid" => orcid_from_url(relation.fetch("subj_id", nil)),
                             "doi" => doi_from_url(relation.fetch("obj_id", nil)),
                             "source_id" => relation.fetch("source_id", nil) } }

      Maremma.post push_url, data: claim, token: access_token
    end
  end
end
