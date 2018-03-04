class MemberSerializer
  include FastJsonapi::ObjectSerializer

  cache_options enabled: true, cache_length: 12.hours

  attributes :id, :title, :description, :member_type, :region, :country, :year, :logo_url, :email, :website, :phone, :created, :updated
end
