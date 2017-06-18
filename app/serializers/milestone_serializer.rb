class MilestoneSerializer < ActiveModel::Serializer
  attributes :url, :title, :description, :open_issues, :closed_issues, :year, :quarter, :created, :updated, :closed, :released

  def url
    "#{ENV["GITHUB_ISSUES_REPO_URL"]}/milestone/#{object.id}"
  end

  def description
    GitHub::Markdown.render_gfm(object.description)
  end

  def created
    object.created_at
  end

  def updated
    object.updated_at
  end

  def closed
    object.closed_at
  end

  def released
    object.released_at
  end
end
