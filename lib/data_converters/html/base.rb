require "base64"
require 'socket'
require 'net/http'
module DataConverters
  module Html 
    class Base
    	def initialize(html)
        @html = html
      end

      def parse
      	if @html.present?
      		{ 
            source: source,
      		  category: category,
      		  lat: lat,
            long: long,
            accuracy: accuracy,
            geolocation_status: geolocation_status,
            min_lat: min_lat,
            max_lat: max_lat, 
            min_long: min_long,
            max_long: max_long,
            country: country,
            state: state,
            metro: metro,
            region: region,
            county: county,
            city: city,
            locality: locality,
            zipcode: zipcode,
      		  external_id: external_id,
      		  external_url: external_url,
      		  heading: heading,
      		  body: body,
      		  html: html,
      		  timestamp: timestamp,
      		  expires: expires,
      		  language: language,
      		  price: price,
      		  currency: currency,
      		  images: images,
      		  annotations: annotations,
      		  status: status,
      		  state: state,
      		  deleted: deleted,
      		  immortal: immortal,
      		  flagged_status: flagged_status,
            formatted_address: formatted_address
          }    
      	end	
      end	

      protected
        def fetch_field(regexp,source = @html)
        	res = regexp.match source
        	res[1] if res
        end 	

        def source
        	raise NotImplementedError.new("You must implement source")
        end

        def category
        	raise NotImplementedError.new("You must implement category")
        end
        
        def lat
        	raise NotImplementedError.new("You must implement lat")
        end

        def long
          raise NotImplementedError.new("You must implement long")
        end

        def accuracy
          raise NotImplementedError.new("You must implement accuracy")
        end
        
        def geolocation_status
          raise NotImplementedError.new("You must implement accuracy")
        end

        def min_lat
          raise NotImplementedError.new("You must implement min_lat")
        end

        def max_lat
          raise NotImplementedError.new("You must implement max_lat")
        end
        
        def min_long
          raise NotImplementedError.new("You must implement min_long")
        end

        def max_long
          raise NotImplementedError.new("You must implement max_long")
        end

        def country
          raise NotImplementedError.new("You must implement country")
        end

        def state
          raise NotImplementedError.new("You must implement state")
        end

        def metro
          raise NotImplementedError.new("You must implement metro")
        end

        def region
          raise NotImplementedError.new("You must implement region")
        end

        def county
          raise NotImplementedError.new("You must implement county")
        end

        def city
          raise NotImplementedError.new("You must implement city")
        end
        
        def locality
          raise NotImplementedError.new("You must implement locality")
        end

        def zipcode
          raise NotImplementedError.new("You must implement zipcode")
        end
        
        def external_id
        	raise NotImplementedError.new("You must implement external_id")
        end

        def external_url
        	raise NotImplementedError.new("You must implement external_url")
        end

        def heading
        	raise NotImplementedError.new("You must implement heading")
        end

        def body
        	raise NotImplementedError.new("You must implement body")
        end

        def html
        	raise NotImplementedError.new("You must implement html")
        end

        def timestamp
        	raise NotImplementedError.new("You must implement timestamp")
        end

        def expires
        	raise NotImplementedError.new("You must implement expires")
        end

        def language
        	raise NotImplementedError.new("You must implement language")
        end

        def price
        	raise NotImplementedError.new("You must implement price")
        end

        def currency
        	raise NotImplementedError.new("You must implement currency")
        end

        def images
        	raise NotImplementedError.new("You must implement images")
        end

        def annotations
        	raise NotImplementedError.new("You must implement annotations")
        end

        def status
        	raise NotImplementedError.new("You must implement status")
        end

        def state
        	raise NotImplementedError.new("You must implement state")
        end

        def deleted
        	raise NotImplementedError.new("You must implement deleted")
        end

        def immortal
        	raise NotImplementedError.new("You must implement immortal")
        end

        def flagged_status
        	raise NotImplementedError.new("You must implement flagged_status")
        end

        def formatted_address
          raise NotImplementedError.new("You must implement formatted_address")
        end
  	end
  end  
end