require 'spec_helper'

describe GeoLocations::ProcessDataService do
  describe '.perform' do
    let(:location_params) { {"lat" => "23.05","long" => "23.04","city" => "Barrie","state" => "CA","country" => "USA","zipcode" => "1300"} }

    context 'success' do
      context 'posting with incoming location values' do
        let(:posting) { FactoryGirl.create(:posting, already_geolocated: true) }
        subject { GeoLocations::ProcessDataService.new(posting, location_params).perform }

        its(:city) { should eq('Barrie') }
        its(:country) { should eq('USA') }
        its(:zipcode) { should eq('1300') }
        its(:state) { should eq('CA') }
        its(:metro) { should be_blank }
        its(:county) { should be_blank }
      end

      context 'completes with missing fields from db' do
        let(:posting) { FactoryGirl.create(:posting, already_geolocated: true) }
        let!(:location) { FactoryGirl.create(:location, metro: 'tesla', county: 'california', code: '1300')}

        subject { GeoLocations::ProcessDataService.new(posting, location_params).perform }

        its(:metro) { should eq('tesla') }
        its(:county) { should eq('california') }
      end
    end

    context 'by lat and long' do
      let(:posting) { FactoryGirl.create(:posting, already_geolocated: false) }

      GEO_LOCATION_DATA = {"10__20" => ["USA","CA","rails"]}
      let(:location_params) { {"lat" => "20","long" => "10"} }
      subject { GeoLocations::ProcessDataService.new(posting, location_params).perform }

      its(:country) { should eq('USA') }
      its(:state) { should eq('CA') }
      its(:metro) { should eq('rails') }
    end
  end
end
