require 'spec_helper'

describe Orcid, type: :model, vcr: true do
  context "get_doi_ra" do
    it "crossref" do
      doi = "10.1016/J.INOCHE.2014.11.004"
      expect(subject.get_doi_ra(doi, test: true)).to eq("crossref")
    end

    it "datacite" do
      doi = "10.5517/CC13D9MF"
      expect(subject.get_doi_ra(doi, test: true)).to eq("datacite")
    end
  end
end
