module DataConverters
  class Oodle < DataConverters::Base
    include DataConverters::LocationConverter

    SOURCE = 'OODLE'
    DEFAULT_STATUS = 'for_sale'
    NOT_ALLOWED_STATUS = 'offered'

    convert :status, :accuracy, :geolocation_status

    protected

    def status
      data[:status] = DEFAULT_STATUS if data[:status].blank? || data[:status] == NOT_ALLOWED_STATUS
    end

  end
end