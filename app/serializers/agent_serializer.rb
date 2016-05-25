class AgentSerializer < ActiveModel::Serializer
  cache key: 'agent'
  attributes :title, :description, :count, :scheduled

  def id
    object.name
  end

  def scheduled
    object.scheduled_at
  end

  def updated
    object.updated_at
  end
end
