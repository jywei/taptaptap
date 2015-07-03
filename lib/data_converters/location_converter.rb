module DataConverters::LocationConverter
  def accuracy
    data[:accuracy] =   if data[:zipcode].present?
                          8
                        else
                          add_error(:formatted_address, 'is required') if data[:formatted_address].nil?
                          commas = (data[:formatted_address] || '').split(',').size - 1
                          if commas == 2
                            6
                          elsif commas == 1
                            2
                          elsif commas == 0
                            1
                          else
                            nil
                          end
                        end
  end

  def geolocation_status
    data[:geolocation_status] = Posting::GeoStatus::NOT_FOR_LOCATION
    if data[:zipcode].present?
      if data[:source] == 'OODLE'
        SULO1.info data[:zipcode]
      end
      lat_and_long = ZipCode.find_by_zipcode(data[:zipcode])
      if lat_and_long.present?
        if data[:source] == 'OODLE'
          SULO1.info lat_and_long
        end
        data[:lat] = lat_and_long['lat']
        data[:long] = lat_and_long['long']
        data[:geolocation_status] = Posting::GeoStatus::TO_LOCATE
      else
        if data[:source] == 'OODLE'
          SULO1.info "no lat_and_long"
        end
      end
    end
  end
end
