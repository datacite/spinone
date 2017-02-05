require 'rails_helper'

describe Person, type: :model, vcr: true do
  it "people" do
    people = Person.where(rows: 50)[:data]
    expect(people.length).to eq(50)
    person = people.first
    expect(person.literal).to eq("Ramesh A")
  end

  it "people with query" do
    people = Person.where(query: "0000-0001-6528-2027")[:data]
    expect(people.length).to eq(1)
    person = people.first
    expect(person.family).to eq("Fenner")
  end

  it "person" do
    person = Person.where(id: "0000-0001-6528-2027")[:data]
    expect(person.family).to eq("Fenner")
  end
end
