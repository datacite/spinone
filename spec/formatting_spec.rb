require 'spec_helper'

describe Orcid, type: :model do
  context "DOI validation" do
    it "10.5555/123" do
      doi = "10.5555/123"
      expect(subject.validated_doi(doi)).to eq(doi)
    end

    it "8.5555/123" do
      doi = "8.5555/123"
      expect(subject.validated_doi(doi)).to be_nil
    end

    it "10.5555" do
      doi = "10.5555"
      expect(subject.validated_doi(doi)).to be_nil
    end

    it "NULL" do
      doi = "NULL"
      expect(subject.validated_doi(doi)).to be_nil
    end

    it "blank" do
      doi = ""
      expect(subject.validated_doi(doi)).to be_nil
    end
  end

  context "ORCID validation" do
    it "0000-0002-1825-0097" do
      orcid = "0000-0002-1825-0097"
      expect(subject.validated_orcid(orcid)).to eq(orcid)
    end

    it "0000-0002-1825-009X" do
      orcid = "0000-0002-1825-009X"
      expect(subject.validated_orcid(orcid)).to eq(orcid)
    end

    it "http://orcid.org/0000-0002-1825-0097" do
      orcid = "http://orcid.org/0000-0002-1825-0097"
      expect(subject.validated_orcid(orcid)).to eq("0000-0002-1825-0097")
    end

    it "0000-0002-1825" do
      orcid = "0000-0002-1825"
      expect(subject.validated_orcid(orcid)).to be_nil
    end
  end
end
