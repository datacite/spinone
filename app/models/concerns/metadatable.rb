module Metadatable
  extend ActiveSupport::Concern

  included do
    # remove non-printing whitespace
    def clean_doi(doi)
      doi.gsub(/\u200B/, '')
    end

    def github_from_url(url)
      return {} unless /\Ahttps:\/\/github\.com\/(.+)(?:\/)?(.+)?(?:\/tree\/)?(.*)\z/.match(url)
      words = URI.parse(url).path[1..-1].split('/')

      { owner: words[0],
        repo: words[1],
        release: words[3] }.compact
    end

    def github_repo_from_url(url)
      github_from_url(url).fetch(:repo, nil)
    end

    def github_release_from_url(url)
      github_from_url(url).fetch(:release, nil)
    end

    def github_owner_from_url(url)
      github_from_url(url).fetch(:owner, nil)
    end

    def github_as_owner_url(github_hash)
      "https://github.com/#{github_hash[:owner]}" if github_hash[:owner].present?
    end

    def github_as_repo_url(github_hash)
      "https://github.com/#{github_hash[:owner]}/#{github_hash[:repo]}" if github_hash[:repo].present?
    end

    def github_as_release_url(github_hash)
      "https://github.com/#{github_hash[:owner]}/#{github_hash[:repo]}/tree/#{github_hash[:release]}" if github_hash[:release].present?
    end
  end
end
