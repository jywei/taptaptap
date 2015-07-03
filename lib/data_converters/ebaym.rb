module DataConverters
  class Ebaym < DataConverters::Base
    include DataConverters::LocationConverter

    SOURCE = 'EBAYM'
    DEFAULT_STATUS = 'for_sale'
    NOT_ALLOWED_STATUS = 'offered'

    #convert :source, :status, :accuracy, :geolocation_status

    protected

    def source
      data[:source] = SOURCE
    end

    def status
      data[:status] = data[:status].keys.first if data[:status].kind_of?(Hash)
      data[:status] = DEFAULT_STATUS if data[:status].blank? || data[:status] == NOT_ALLOWED_STATUS
    end
  end
end
