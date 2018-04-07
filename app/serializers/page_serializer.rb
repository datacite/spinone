class PageSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash

  attributes :id, :author, :title, :container_title, :description, :license, :url, :image_url, :tags, :issued, :updated
end
