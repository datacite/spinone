class MemberSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  
  set_type :members
  cache_options enabled: true, cache_length: 12.hours
  attributes :title, :description, :member_type, :region, :country, :year, :logo_url, :email, :website, :phone, :created, :updated
end
