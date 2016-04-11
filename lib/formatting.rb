require 'sinatra/base'
require 'namae'
require 'json'

module Sinatra
  module Formatting
    # Format used for DOI validation
    # The prefix is 10.x where x is 4-5 digits. The suffix can be anything, but can"t be left off
    DOI_FORMAT = %r(\A10\.\d{4,5}/.+)

    # Format used for ORCID validation
    ORCID_FORMAT = %r(\A(?:http:\/\/orcid\.org\/)?(\d{4}-\d{4}-\d{4}-\d{3}[0-9X]+)\z)

    def validated_doi(doi)
      Array(DOI_FORMAT.match(doi)).last
    end

    def validated_orcid(orcid)
      Array(ORCID_FORMAT.match(orcid)).last
    end

    def doi_as_url(doi)
      "http://doi.org/" + doi
    end

    def orcid_as_url(orcid)
      "http://orcid.org/" + orcid
    end

    def number_with_delimiter(number, default_options = {})
      options = { :delimiter => ',' }.merge(default_options)
      number.to_s.reverse.gsub(/(\d{3}(?=(\d)))/, "\\1#{options[:delimiter]}").reverse
    end

    # parse array of author hashes into CSL format
    def get_hashed_authors(authors)
      Array(authors).map { |author| get_one_hashed_author(author) }
    end

    def get_one_hashed_author(author)
      raw_name = author.fetch("creatorName", nil)

      author_hsh = get_one_author(raw_name)
      author_hsh["ORCID"] = get_name_identifier(author)
      author_hsh.compact
    end

    # parse author string into CSL format
    def get_one_author(author)
      return "" if author.blank?

      names = Namae.parse(author)
      if names.present?
        name = names.first

        { "family" => name.family,
          "given" => name.given }.compact
      else
        { "literal" => author }
      end
    end

    def get_name_identifier(author)
      name_identifier = author.fetch("nameIdentifier", nil)
      name_identifier_scheme = author.fetch("nameIdentifierScheme", "orcid").downcase
      if name_identifier.present? && name_identifier_scheme == "orcid"
        "http://orcid.org/#{name_identifier}"
      else
        nil
      end
    end

    def worker_label(status)
      case status
      when "working" then "panel-success"
      when "waiting" then "panel-default"
      else "panel-warning"
      end
    end

    def format_time(time)
      Time.iso8601(time).strftime("%d %b %H:%M UTC") if time.present?
    end

    def from_json(string)
      ::JSON.parse(string)
    rescue ::JSON::ParserError => e
      { errors: [{ status: 422,
                   title: "Request must contain valid JSON",
                   detail: e.message }] }
    end
  end

  helpers Formatting
end
