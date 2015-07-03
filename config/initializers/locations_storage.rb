path = Rails.root + 'system_files/CL_Locations.xls'
GEO_LOCATION_DATA = LoadLocationsFromXlsService.new(path.to_s).perform
