class Status < ActiveRecord::Base
  RELEASES_URL = "https://api.github.com/repos/datacite/spinone/releases"

  before_create :collect_status_info, :create_uuid

  default_scope { order("status.created_at DESC") }

  def self.per_page
    1000
  end

  def to_param
    uuid
  end

  def collect_status_info
    self.datacite_orcid_count = agent_counts.fetch("datacite_orcid", 0)
    self.datacite_github_count = agent_counts.fetch("datacite_github", 0)
    self.datacite_related_count = agent_counts.fetch("datacite_related", 0)
    self.orcid_update_count = agent_counts.fetch("orcid_update", 0)
    self.db_size = get_db_size
    self.version = Spinone::VERSION
    self.current_version = get_current_version unless current_version.present?
  end

  def agent_counts
    Agent.all.to_a.map { |a| [a.name, a.count] }.to_h
  end

  def get_current_version
    result = Maremma.get RELEASES_URL
    result = result.is_a?(Array) ? result.first : nil
    result.to_h.fetch("tag_name", "v.#{version}")[2..-1]
  end

  # get combined data and index size for all tables
  def get_db_size
    sql = "SELECT SUM(DATA_LENGTH + INDEX_LENGTH) as size FROM information_schema.TABLES where TABLE_SCHEMA = '#{ENV['DB_NAME'].to_s}';"
    result = ActiveRecord::Base.connection.exec_query(sql)
    result.rows.first.reduce(:+)
  end

  def outdated_version?
    Gem::Version.new(current_version) > Gem::Version.new(version)
  end

  def timestamp
    updated_at.utc.iso8601
  end

  def create_uuid
    write_attribute(:uuid, SecureRandom.uuid)
  end
end
