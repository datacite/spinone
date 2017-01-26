require 'cgi'

class Base
  extend ActiveModel::Naming
  include ActiveModel::Serialization

  DEFAULT_ROWS = 1000

  def self.all
    collect_data
  end

  def self.where(options={})
    collect_data(options)
  end

  def self.collect_data(options = {})
    data = get_data(options)
    parse_data(data, options)
  end

  def self.get_data(options={})
    query_url = get_query_url(options)
    Maremma.get(query_url, options)
  end

  def self.parse_item(item, options={})
    self.new(item, options)
  end

  def self.parse_items(items, options={})
    Array(items).map do |item|
      parse_item(item, options)
    end
  end

  def self.parse_include(klass, params)
    klass.new(params)
  end

  def self.sanitize(text, options={})
    Bergamasco::Sanitize.sanitize(text, options)
  end

  def self.db
    db_name = ENV['MDS_DB_NAME']
    db_username = ENV['MDS_DB_USERNAME']
    db_password = ENV['MDS_DB_PASSWORD']
    db_host = ENV['MDS_DB_HOST']

    Sequel.connect("mysql2://#{db_username}:#{db_password}@#{db_host}/#{db_name}")
  end
end
