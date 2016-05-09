class AgentSerializer < ActiveModel::Serializer
  cache key: 'agent'
  attributes :title, :description, :count, :scheduled_at

  def id
    object.name
  end
end
