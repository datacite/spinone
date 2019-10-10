# frozen_string_literal: true

class FunderType < BaseObject
  key fields: 'id'
  
  description "Information about funders"

  field :id, ID, null: false, description: "Crossref Funder ID"
  field :type, String, null: false, description: "The type of the item."
  field :name, String, null: false, description: "The name of the funder."
  field :alternate_name, [String], null: true, description: "An alias for the funder."
  field :address, AddressType, null: true, description: "Physical address of the funder."

  def type
    "Funder"
  end
  
  def address
    { "type" => "postalAddress",
      "address_country" => object.country.to_h.fetch("name", nil) }
  end
end
