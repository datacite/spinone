class Base
  extend ActiveModel::Naming
  include ActiveModel::Serialization

  def self.all
    collect_data
  end

  def self.find(id)
    collect_data(id: id)
  end

  def self.collect_data(options = {})
    data = get_data(options)
    parse_data(data, options)
  end

  def self.get_data(options={})
    query_url = get_query_url(options)
    Maremma.get(query_url, options)
  end
end
