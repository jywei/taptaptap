# ZipCode.find_by_zipcode(@posting[:zipcode])

require 'spec_helper'

describe ZipCode do
  before do
    ZipCode.create zipcode: '501', lat: 40.8154, long: -73.0456
  end

  context "fetching zipcode" do
    before do
      @zipcode = ZipCode.find_by_zipcode('501')
    end

    it "should return as a hash, not an array" do
      expect(@zipcode).to be_a(Hash)
      expect(@zipcode['lat']).not_to be_nil
      expect(@zipcode['long']).not_to be_nil
      expect(@zipcode[0]).to be_nil
      expect(@zipcode[1]).to be_nil
    end
  end

  context "ignoring heading zeros" do
    before do
      @zipcode = ZipCode.find_by_zipcode('00501')
    end

    it "should return as a hash, not an array" do
      expect(@zipcode).to be_a(Hash)
      expect(@zipcode['lat']).not_to be_nil
      expect(@zipcode['long']).not_to be_nil
      expect(@zipcode[0]).to be_nil
      expect(@zipcode[1]).to be_nil
    end
  end
end
