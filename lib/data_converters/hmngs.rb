module DataConverters
  class Hmngs < DataConverters::Base
    include DataConverters::LocationConverter

    DEFAULT_STATUS = 'for_sale'

    convert :status, :accuracy, :geolocation_status

    def status
      data[:status] = data[:status].keys.first if data[:status].kind_of? Hash
      data[:status] = DEFAULT_STATUS if data[:status].blank?
    end

  end
end
