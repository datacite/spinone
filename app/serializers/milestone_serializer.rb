class MilestoneSerializer < ActiveModel::Serializer
  attributes :title, :description, :open_issues, :closed_issues, :year, :quarter, :created, :updated, :closed, :released

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
