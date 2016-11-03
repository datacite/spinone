require 'rails_helper'

describe Contribution, type: :model, vcr: true do
  it "contributions" do
    result = Contribution.where(rows: 50)
    contributions = result[:data]
    contribution = contributions.first
    expect(contribution.credit_name).to eq("Nicholas Mason")
    expect(contribution.is_a?(Contribution)).to eq(true)
  end

  it "contributions with filter by source" do
    contributions = Contribution.where("source-id" => "datacite-search-link")[:data]
    contribution = contributions.first
    expect(contribution.title).to eq("Why Cooperative Banks Are Particularly Important at a Time of Credit Crunch")
    expect(contribution.source.title).to eq("DataCite (ORCID Search and Link)")
  end

  it "contributions with publishers" do
    contributions = Contribution.where("publisher-id" => "tib.pangaea")[:data]
    contribution = contributions.first
    expect(contribution.title).to eq("Halogen deposition in polar snow and ice, supplement to: Spolaor, Andrea; Vallelonga, Paul; Gabrieli, J; Martma, Tõnu; Björkman, MP; Isaksson, Elisabeth; Cozzi, Giulio; Turetta, C; Kjær, Helle A; Curran, MAJ; Moy, AD; Schönhardt, Anja; Blechschmidt, A-M; Burrows, John P; Plane, JMC; Barbante, Carlo (2014): Seasonality of halogen deposition in polar snow and ice. Atmospheric Chemistry and Physics, 14(6), 9613-9622")
    expect(contribution.publisher.title).to eq("PANGAEA - Publishing Network for Geoscientific and Environmental Data")
  end
end
