class IndexController < ApplicationController
  def index
    meta = { meta: { name: ENV['SITENAMELONG'] }}.to_json
    render json: meta
  end
end
