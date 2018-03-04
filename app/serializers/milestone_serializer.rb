class MilestoneSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :url, :title, :description, :open_issues, :closed_issues, :year, :quarter, :created, :updated, :closed, :released
end
