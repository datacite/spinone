class UserStorySerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :url, :title, :description, :comments, :categories, :stakeholders, :state, :inactive, :milestone, :created, :updated, :closed
end
