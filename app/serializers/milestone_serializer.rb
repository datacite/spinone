class MilestoneSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  
  attributes :id, :url, :title, :description, :open_issues, :closed_issues, :year, :quarter, :created, :updated, :closed, :released
end
