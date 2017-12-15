require 'rails_helper'

describe Work do
  describe "get_one_author" do
    it 'should handle author in comma-delimited format' do
      author = { "creatorName" => "Zaranek, Alexander W." }
      result = subject.get_one_author(author)
      expect(result).to eq("given"=>"Alexander W.", "family"=>"Zaranek")
    end

    it 'should handle authors with incomplete names' do
      author = { "creatorName" => "Zaranek" }
      result = subject.get_one_author(author)
      expect(result).to eq("literal"=>"Zaranek")
    end

    it 'should ignore names that are not comma-delimited' do
      author = { "creatorName" => "Zaranek University" }
      result = subject.get_one_author(author)
      expect(result).to eq("literal"=>"Zaranek University")
    end

    it 'should handle ORCID identifiers' do
      author = { "creatorName" => "Moore, Jonathan",
                 "nameIdentifier" => "0000-0002-5486-0407" }
      result = subject.get_one_author(author)
      expect(result).to eq("family"=>"Moore", "given"=>"Jonathan", "ORCID"=>"https://orcid.org/0000-0002-5486-0407")
    end

    it 'should handle incorrect ORCID identifiers' do
      author = { "creatorName" => "Moore, Jonathan",
                 "nameIdentifier" => "0000" }
      result = subject.get_one_author(author)
      expect(result).to eq("given"=>"Jonathan", "family"=>"Moore")
    end
  end

  describe "cleanup_author" do
    it 'should titleize names' do
      author = "madeline p. ball"
      result = subject.cleanup_author(author)
      expect(result).to eq("Madeline P. Ball")
    end

    it 'should handle hyphens in names' do
      author = "madeline p. ball-regiers"
      result = subject.cleanup_author(author)
      expect(result).to eq("Madeline P. Ball-Regiers")
    end

    it 'should handle camel case in names' do
      author = "Madeline MacMahon"
      result = subject.cleanup_author(author)
      expect(result).to eq("Madeline MacMahon")
    end

    it 'should detect name initials' do
      author = "Ball M.P."
      result = subject.cleanup_author(author)
      expect(result).to eq("Ball, M.P.")
    end

    it 'should detect name initials with hypen' do
      author = "Ball M.-P."
      result = subject.cleanup_author(author)
      expect(result).to eq("Ball, M.-P.")
    end

    it 'should handle special whitespace characters in names' do
      author = "Pampel, Heinz"
      result = subject.cleanup_author(author)
      expect(result).to eq("Pampel, Heinz")
    end
  end

  describe "is_personal_name?" do
    it 'should detect institution name' do
      author = { "name" => "Project THOR" }
      result = subject.is_personal_name?(author)
      expect(result).to be false
    end
  end
end
