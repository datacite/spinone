class UserStorySerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  
  set_type "user-stories"
  attributes :id, :url, :title, :description, :comments, :projects, :stakeholders, :state, :inactive, :milestone, :created, :updated, :closed
end
