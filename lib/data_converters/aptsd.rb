module DataConverters
  class Aptsd < DataConverters::Base
    include DataConverters::LocationConverter

    DEFAULT_STATUS = 'for_rent'
    NOT_ALLOWED_STATUS = 'offered'

    convert :status, :accuracy, :geolocation_status

    protected

    def status
      data[:status] = DEFAULT_STATUS if data[:status].blank? || data[:status] == NOT_ALLOWED_STATUS
    end
  end
end