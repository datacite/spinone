module Authorable
  extend ActiveSupport::Concern

  require "namae"

  included do
    IDENTIFIER_SCHEME_URIS = {
      "ORCID" => "https://orcid.org/"
    }

    def get_one_author(author)
      orcid = get_name_identifier(author)

      given_name = author.fetch("givenName", nil)
      family_name = author.fetch("familyName", nil)

      if (given_name.present? || family_name.present?)
        return { "given" => given_name,
                 "family" => family_name,
                 "ORCID" => orcid }.compact
      elsif is_personal_name?(author)
        name = get_name(author)

        names = Namae.parse(name)
        parsed_name = names.first

        if parsed_name.present?
          given_name = parsed_name.given
          family_name = parsed_name.family
        else
          given_name = nil
          family_name = nil
        end

        if (given_name.present? || family_name.present?)
          return { "given" => given_name,
                   "family" => family_name,
                   "ORCID" => orcid }.compact
        else
          return { "name" => name,
                   "ORCID" => orcid }.compact
        end
      else
        name = get_name(author)
        { "literal" => name }.compact
      end
    end

    def get_name(author)
      name = parse_attributes(author.fetch("creatorName", nil)) ||
             parse_attributes(author.fetch("contributorName", nil)) ||
             author.fetch("name", nil)
      cleanup_author(name)
    end

    def cleanup_author(author)
      # detect pattern "Smith J.", but not "Smith, John K."
      author = author.gsub(/[[:space:]]([A-Z]\.)?(-?[A-Z]\.)$/, ', \1\2') unless author.include?(",")

      # remove spaces around hyphens
      author = author.gsub(" - ", "-")

      # titleize strings
      # remove non-standard space characters
      author.my_titleize.gsub(/[[:space:]]/, ' ')
    end

    def is_personal_name?(author)
      return true if author.fetch("orcid", "").present? ||
                     author.fetch("familyName", "").present? ||
                     (author.fetch("creatorName", "").include?(",") &&
                     author.fetch("creatorName", "").exclude?(";")) ||
                     (author.fetch("contributorName", "").include?(",") &&
                     author.fetch("contributorName", "").exclude?(";"))
      false
    end

    # parse array of author strings into CSL format
    def get_authors(authors)
      Array.wrap(authors).map { |author| get_one_author(author) }
    end

    # parse nameIdentifier from DataCite
    def get_name_identifier(author)
      name_identifiers = Array.wrap(author.fetch("nameIdentifier", nil)).reduce([]) do |sum, n|
        n = { "__content__" => n } if n.is_a?(String)

        # fetch scheme_uri, default to ORCID
        scheme = n.fetch("nameIdentifierScheme", nil)
        scheme_uri = n.fetch("schemeURI", nil) || IDENTIFIER_SCHEME_URIS.fetch(scheme, "https://orcid.org")
        scheme_uri = "https://orcid.org/" if validate_orcid_scheme(scheme_uri)
        scheme_uri << '/' unless scheme_uri.present? && scheme_uri.end_with?('/')

        identifier = n.fetch("__content__", nil)
        if scheme_uri == "https://orcid.org/"
          identifier = validate_orcid(identifier)
        else
          identifier = identifier.gsub(" ", "-")
        end

        if identifier.present? && scheme_uri.present?
          sum << scheme_uri + identifier
        else
          sum
        end
      end

      # return array of name identifiers, ORCID ID is first element if multiple
      name_identifiers.find { |n| n.start_with?("https://orcid.org") }
    end

    def parse_attributes(element, options={})
      content = options[:content] || "__content__"

      if element.is_a?(String)
        element
      elsif element.is_a?(Hash)
        element.fetch(content, nil)
      elsif element.is_a?(Array)
        a = element.map { |e| e.is_a?(Hash) ? e.fetch(content, nil) : e }.uniq
        a = options[:first] ? a.first : a.unwrap
      else
        nil
      end
    end
  end
end
