describe GeoApi do
  describe '.locations' do
    context 'for all params' do
      let(:params) {{ latitude: '20.2', longitude: '-12.4', accuracy: '2', bounds_min_lat: '0', bounds_max_lat: '30', bounds_min_long: '-30', bounds_max_long: '0' }}

      it 'returns list with locations' do
        geolocation_url = 'http://geolocator.3taps.com/reverse/?latitude=20.2&longitude=-12.4&accuracy=2&bounds_min_lat=0&bounds_max_lat=30&bounds_min_long=-30&bounds_max_long=0'
        GeoApi.should_receive(:fetch_locations).with(geolocation_url).and_return({success: true, city: 'Kiyv', country: 'Ukraine'}.to_json)
        expect(GeoApi.locations(params)).to eq({city: 'Kiyv', country: 'Ukraine'})
      end
    end

    context 'for only lat and long params' do
      let(:params) {{ latitude: '20.2', longitude: '-12.4', accuracy: nil, bounds_min_lat: nil, bounds_max_lat: nil, bounds_min_long: nil, bounds_max_long: nil }}

      it 'returns list with locations' do
        geolocation_url = 'http://geolocator.3taps.com/reverse/?latitude=20.2&longitude=-12.4'
        GeoApi.should_receive(:fetch_locations).with(geolocation_url).and_return({success: true, city: 'Kiyv', country: 'Ukraine'}.to_json)
        expect(GeoApi.locations(params)).to eq({city: 'Kiyv', country: 'Ukraine'})
      end
    end

    context 'for not real lat and long params' do
      let(:params) {{ latitude: '0', longitude: '0'}}

      it 'returns nil' do
        geolocation_url = 'http://geolocator.3taps.com/reverse/?latitude=0&longitude=0'
        GeoApi.should_receive(:fetch_locations).with(geolocation_url).and_return({success: false, error: 'No results found'}.to_json)
        expect(GeoApi.locations(params)).to be_empty
      end
    end
  end
end
