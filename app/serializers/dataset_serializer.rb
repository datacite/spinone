class DatasetSerializer < ActiveModel::Serializer
  cache key: 'dats'
  attributes :identifiers, :title, :types, :creators, :dates, :container_title, :description

  type :dats

  def identifiers
    [{ "identifier" => "doi:#{object.doi}",
       "identifier-source" => "DataCite" }]
  end

  def types
    [{ "information" => { "value" => object.resource_type } }]
  end

  def dates
    [{ "date" => object.published,
       "type" => { "ontologyTermIRI" => "http://schema.datacite.org/meta/kernel-3.1/metadata.xsd", "value" => "publicationYear" }
     },
     { "date" => object.registered,
       "type" => { "ontologyTermIRI" => "http://schema.datacite.org/meta/kernel-3.1/metadata.xsd", "value" => "Issued" }
     },
     { "date" => object.updated_at,
       "type" => { "ontologyTermIRI" => "http://schema.datacite.org/meta/kernel-3.1/metadata.xsd", "value" => "Updated" }
     }]
  end

  def updated
    object.updated_at
  end

  def creators
    object.author.map { |a| { "first-name" => a["given"], "last-name" => a["family"] } }
  end
end
