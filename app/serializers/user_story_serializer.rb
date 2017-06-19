class UserStorySerializer < ActiveModel::Serializer
  attributes :url, :title, :description, :comments, :categories, :stakeholders, :state, :inactive, :milestone, :created, :updated, :closed

  def url
    "#{ENV["GITHUB_ISSUES_REPO_URL"]}/issues/#{object.id}"
  end

  def description
    GitHub::Markdown.render_gfm(object.description)
  end

  def milestone
    m = object.milestone
    if m.present?
      { "id" => m['number'],
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
