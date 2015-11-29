require 'sinatra/base'
require 'namae'

module Sinatra
  module Formatting
    def worker_label(status)
      case status
      when "working" then "panel-success"
      when "waiting" then "panel-default"
      else "panel-warning"
      end
    end

    def doi_as_url(doi)
      "http://doi.org/" + doi
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

    def format_time(time)
      Time.iso8601(time).strftime("%d %b %H:%M UTC") if time.present?
    end
  end

  helpers Formatting
end
