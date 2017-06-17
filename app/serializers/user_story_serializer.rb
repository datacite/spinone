class UserStorySerializer < ActiveModel::Serializer
  attributes :title, :description, :comments, :categories, :stakeholders, :state, :milestone, :created, :updated, :closed

  def id
    "#{ENV["GITHUB_ISSUES_REPO_URL"]}/issues/#{object.id}"
  end

  def description
    GitHub::Markdown.render_gfm(object.description)
  end

  def categories
    object.categories.presence
  end

  def stakeholders
    object.stakeholders.presence
  end

  def milestone
    m = object.milestone
    if m.present?
      { "url" => "#{ENV["GITHUB_ISSUES_REPO_URL"]}/milestone/#{m['number']}",
        "title" => m["title"] }
    end
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
end
