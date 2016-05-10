class SourceSerializer < ActiveModel::Serializer
  cache key: 'source'
  attributes :title, :description, :state, :group_id, :work_count, :relation_count, :result_count, :by_day, :by_month, :updated_at
end
