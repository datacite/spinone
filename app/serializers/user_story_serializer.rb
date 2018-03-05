class UserStorySerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :url, :title, :description, :comments, :projects, :stakeholders, :state, :inactive, :milestone, :created, :updated, :closed
end
