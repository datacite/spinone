module Authorable
  extend ActiveSupport::Concern

  require "namae"

  included do
    def get_one_author(author)
      name = cleanup_author(author)

      if is_personal_name?(name)
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
          { "given" => given_name,
            "family" => family_name }.compact
        else
          { "name" => name }.compact
        end
      else
        { "literal" => name }.compact
      end
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
      author.include?(",") && author.exclude?(";")
    end

    # parse array of author strings into CSL format
    def get_authors(authors)
      Array.wrap(authors).map { |author| get_one_author(author) }
    end
  end
end
