require 'nokogiri'
require 'base64'
require_relative 'related_identifier'

class DataciteCrossref < RelatedIdentifier
  def name
    'datacite_crossref'
  end

  def title
    'DataCite (Crossref)'
  end

  def description
    'Import works with Crossref DOIs as relatedIdentifier via the DataCite Solr API.'
  end

  def source_id
    'datacite_crossref'
  end

  def get_relations(subj, items)
    prefix = subj["DOI"][/^10\.\d{4,5}/]

    Array(items).reduce([]) do |sum, item|
      raw_relation_type, _related_identifier_type, related_identifier = item.split(':', 3)
      doi = related_identifier.strip.upcase

      registration_agency = get_doi_ra(doi)

      if registration_agency != "crossref"
        sum
      else
        sum <<  { prefix: prefix,
                  relation: { "subj_id" => subj["pid"],
                              "obj_id" => doi_as_url(doi),
                              "relation_type_id" => raw_relation_type.underscore,
                              "source_id" => "datacite_crossref",
                              "publisher_id" => subj["publisher_id"] },
                  subj: subj }
      end
    end
  end

  def uuid
    ENV['DATACITE_CROSSREF_UUID']
  end

  def push_url
    ENV['DATACITE_CROSSREF_URL']
  end

  def access_token
    ENV['DATACITE_CROSSREF_TOKEN']
  end
end
