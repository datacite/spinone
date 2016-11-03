class SourceSerializer < ActiveModel::Serializer
  #cache key: 'source'
  attributes :title, :description, :state, :group_id, :work_count, :relation_count, :result_count, :by_day, :by_month, :updated

  belongs_to :group, serializer: GroupSerializer

  def updated
    object.updated_at
  end
end
