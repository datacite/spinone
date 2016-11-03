require 'rails_helper'

describe Work do
  describe "get_datetime_from_input" do
    it 'year' do
      date = "2015"
      result = Work.get_datetime_from_input(date)
      expect(result).to eq("2015-01-01T00:00:00Z")
    end

    it 'year month' do
      date = "2015-10"
      result = Work.get_datetime_from_input(date)
      expect(result).to eq("2015-10-01T00:00:00Z")
    end

    it 'year month day' do
      date = "2015-10-12"
      result = Work.get_datetime_from_input(date)
      expect(result).to eq("2015-10-12T00:00:00Z")
    end

    it 'year month day until date' do
      date = "2015-10-12"
      result = Work.get_datetime_from_input(date, until_date: true)
      expect(result).to eq("2015-10-12T23:59:59Z")
    end

    it 'invalid date' do
      date = "x"
      result = Work.get_datetime_from_input(date)
      expect(result).to be_nil
    end
  end

  describe "get_solr_date_range" do
    it 'year' do
      from_date = "2015"
      until_date = "2015"
      result = Work.get_solr_date_range(from_date, until_date)
      expect(result).to eq("[2015-01-01T00:00:00Z TO 2015-12-31T23:59:59Z]")
    end

    it 'year month' do
      from_date = "2015-02"
      until_date = "2015-03"
      result = Work.get_solr_date_range(from_date, until_date)
      expect(result).to eq("[2015-02-01T00:00:00Z TO 2015-03-31T23:59:59Z]")
    end

    it 'year month day' do
      from_date = "2015-02-04"
      until_date = "2015-03-15"
      result = Work.get_solr_date_range(from_date, until_date)
      expect(result).to eq("[2015-02-04T00:00:00Z TO 2015-03-15T23:59:59Z]")
    end

    it 'year month day until_date before' do
      from_date = "2015-02-04"
      until_date = "2015-01-15"
      result = Work.get_solr_date_range(from_date, until_date)
      expect(result).to eq("[2015-02-04T00:00:00Z TO 2015-02-04T23:59:59Z]")
    end

    it 'year no from date' do
      from_date = nil
      until_date = "2015"
      result = Work.get_solr_date_range(from_date, until_date)
      expect(result).to eq("[* TO 2015-12-31T23:59:59Z]")
    end

    it 'year month no until date' do
      from_date = "2015-02"
      until_date = nil
      result = Work.get_solr_date_range(from_date, until_date)
      expect(result).to eq("[2015-02-01T00:00:00Z TO *]")
    end
  end
end
