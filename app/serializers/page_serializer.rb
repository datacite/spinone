class PageSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :author, :title, :container_title, :description, :license, :url, :image_url, :tags, :issued, :updated
end
