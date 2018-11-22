class MemberSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  set_type :members

  attributes :title, :description, :member_type, :region, :country, :year, :logo_url, :email, :website, :phone, :created, :updated
end
