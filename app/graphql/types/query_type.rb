# frozen_string_literal: true

class QueryType < BaseObject
  field :funders, FunderConnectionWithMetaType, null: false, connection: true, max_page_size: 100 do
    argument :query, String, required: false
    argument :first, Int, required: false, default_value: 25
  end

  def funders(query: nil, first: nil)
    Funder.query(query, limit: first).fetch(:data, [])
  end

  field :funder, FunderType, null: false do
    argument :id, ID, required: true
  end

  def funder(id:)
    result = Funder.find_by_id(id).fetch(:data, []).first
    fail ActiveRecord::RecordNotFound if result.nil?

    result
  end
end
