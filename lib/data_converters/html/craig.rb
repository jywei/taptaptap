
module DataConverters
  module Html
    class Craig < DataConverters::Html::Base
    
      def annotations
        res = {}
        if category
          annotations_fields = CraigData::CHILD_CATEGORIES_FILDS[category]['annotations']
          if annotations_fields 
            annotations_fields.each do |field|
              if respond_to? field
                some_field = send field
                res[field] = some_field if some_field  
              end  
            end
          end
        end 
        res    
      end  

      def source
        'CRAIG'
      end 

      def category
        @category ||= get_categories CraigData::CRAIG_CHILD_AND_PARENT_CATEGORY_TO_3TAPS_CHILD_CATEGORY
      end
      
      # latitude
      def lat 
        fetch_field(/data-latitude=\"(.*?)\"/m)  
      end  
          
      # longitude
      def long
        fetch_field(/data-longitude=\"(.*?)\"/m)
      end

      def accuracy
        nil
      end

      def geolocation_status
        Posting::GeoStatus::TO_LOCATE
      end

      def min_lat
        nil
      end

      def max_lat
        nil
      end
        
      def min_long
        nil
      end

      def max_long
        nil
      end

      def country
        nil
      end

      def state
        nil
      end

      def metro
        nil
      end

      def region
        get_from_cltags 'region'
      end

      def county
        nil
      end

      def city
        res = get_from_cltags 'city' 
        res = fetch_field(/\(([\w\/\s]*)\)/mi,heading) unless res
      end
        
      def locality
        nil
      end

      def zipcode
        nil
      end
          
      def external_id
        fetch_field(/post\s*id\s*:\s*([0-9]*)/m)
      end

      def external_url
        nil
      end  
        
      def heading
        @heading ||= remove_tags(fetch_field(/<h2 class="postingtitle">(.*?)<\/h2>/m))
      end  
      
      def body
        @body ||= remove_tags(fetch_field(/<section id="postingbody">(.*?)<\/section>/m))
      end  

      # original html
      def html
         Base64.encode64(@html)
      end  
         
      def timestamp
        Time.parse(original_posting_date).to_i if original_posting_date
      end

      def expires
        nil
      end 

      def language
        'EN' 
      end  

      def price
        fetch_field(/&#x0024;([0-9\.\,]*)/,heading)
      end

      def currency
        'USD'
      end  

      def images 
        images_html = fetch_field(/<div id="thumbs">(.*?)<\/div>/m)
        if images_html
          src =  images_html.scan /<img src="(.*?)"/m
          if src
            src.map do |item|
              {
                thumbnail: item.first,
                full: item.first.gsub('50x50c','640x450')
              }
            end
          end 
        else
          src = body.scan /<img(.*?)src="(.*?)"/mi if body
          if src
            src.map do |item|
              {
                full:item.second
              }
            end  
          end  
        end

      end

      #annotations fields

      def status
        stat = 'offered' #default status 
        if fetch_field(/(\bfound\b)/mi, heading)
          stat = 'found' unless fetch_field(/(Page Not Found)/mi, heading)    
        end
        stat = 'found' if fetch_field(/(\brecovered\b)/mi, heading)
        other_status = %w(lost stolen wanted)
        other_status.each { |item| stat = item  if fetch_field(/(\b#{item}\b)/mi,heading) }
        stat
      end

      def phone
        fetch_field(/(\d{3}\W\d{3}\W\d{4})/m,body) || fetch_field(/(\(\d{3}\)\W\d{3}\W\d{4})/m,body)  
      end 

      def bedrooms
        fetch_field(/(\d)br/i)
      end 

      def sqft
        fetch_field(/(\d*?)ft&sup2/mi)
      end 

      def year
        cars_cat = %w(VAUT VOTH VPAR)
        if cars_cat.include? category 
          get_car_data.first if get_car_data 
        else  
          fetch_field(/20\d\d\b/m) || fetch_field(/\b19\d\d\b/m)
        end          
      end  

      def state
        nil
      end 

      def deleted
        1 if fetch_field(/(class="removed")/mi)
      end

      def immortal
        nil
      end

      def flagged_status
        nil
      end  
        
      def make
        get_car_data.second.capitalize if get_car_data 
      end

      def model
        get_car_data.map.with_index{ |v,i|  v.capitalize if i > 1 }.join(' ')  if get_car_data 
      end

      def mileage
        fetch_field(/class="attrbubble">odometer:[\s<b>]*(\d*)[\s<\/b>]*<\/span>/mi) || fetch_field(/mileage:[<>\/\w]*\s*(\d{1,7})/i,body) || fetch_field(/(\d{1,4})k\s(m|miles)/,body).to_i*1000
      end

      def vin
        fetch_field(/([0-9A-HJ-NPR-Z]{17})/m, body)
      end

      def source_loc
        fetch_field(/https?:\/\/(([^.]+))\..*/,breadcrumbs)
      end   
       
      def compensation
        get_from_cltags 'compensation'
      end
      
      def nonprofit
        get_from_cltags 'nonprofit'
      end  

      def part_time
        get_from_cltags 'partTime'
      end
      
      def telecommute
        get_from_cltags 'telecommute'
      end

      def contract
        get_from_cltags 'contract'
      end

      def internship
        get_from_cltags 'internship'
      end

      def scheduling
        get_from_cltags 'scheduling'
      end

      def cats
        get_from_cltags('catsAreOK') ? 'YES' : 'NO'
      end  

      def dogs
        get_from_cltags('dogsAreOK') ? 'YES' : 'NO'
      end

      def personal_flavor
        fetch_field(/(mw4mw|mw4w|mw4m|w4mw|m4mw|w4ww|m4mm|mm4m|ww4w|ww4m|mm4w|m4ww|w4mm|t4mw|mw4t|w4m|m4m|m4w|w4w|t4m|m4t)/im, heading)
      end

      def age
        fetch_field(/([0-9]{1,2})/, heading)
      end 

      def source_neighborhood
        get_from_cltags 'GeographicArea'
      end  

      def source_continent

      end 

      def source_state
        city
      end  

      def source_cat
        @source_cat ||= get_categories CraigData::CRAIG_PARENT_TO_CHILD_CATEGORY
      end 

      def source_subcat
        if get_source_sub_cat 
          [get_source_sub_cat, craig_category].join('|')
        else
          craig_category
        end  
      end 

      def proxy_ip

      end

      def source_account

      end

      def original_posting_date
        @original_posting_date ||= fetch_field(/Posted: <time datetime="(.+?)">/)
      end

      def source_map_google
        if fetch_field(/maps.yahoo.com\/(.*)">yahoo map<\/a>/mi)
          "http://maps.google.com/"+fetch_field(/maps.google.com\/(.*)">google map<\/a>/mi)
        end
      end

      def source_map_yahoo
        if fetch_field(/maps.yahoo.com\/(.*)">yahoo map<\/a>/mi)
          "http://maps.yahoo.com/"+fetch_field(/maps.yahoo.com\/(.*)">yahoo map<\/a>/mi)
        end  
      end 

      def formatted_address
        res = []
        res << city if city
        crumbs = breadcrumbs.scan /a href=".*?">([\w\s]*)/mi
        if crumbs
          res << crumbs.second
        end   
        res.join(",").titleize if !res.empty?
      end 

      private

        def breadcrumbs
          if @html
            doc = Nokogiri::HTML(@html)
            doc.css(".crumb").to_s
          end  
        end  

        def craig_category
          @craig_category ||= fetch_field(/<a href=".*\/([a-z]{3})\/">.*<\/a>/m, breadcrumbs)
        end 

        def get_source_sub_cat
          @source_subcat ||= get_categories CraigData::CRAIG_PARENT_SUB_TO_CHILD_CATEGORY
        end  

        def get_categories(data)
          cat = nil
          if data && craig_category
            data.each do |key, categories|
              if categories.include? craig_category
                cat = key
                break
              end  
            end        
          end
          cat  
        end  

        def get_cltags
          tags = fetch_field(/START CLTAGS(.*?)END CLTAGS/m)
          if tags
            tag = tags.scan /CLTAG (.*?)=(.*?) -->/im
            Hash[tag]
          end  
        end  
        
        def cltags
          @cltags ||= get_cltags
        end 

        def get_from_cltags(field)
          res = nil
          if cltags
            res = cltags.fetch field if cltags.include? field  
          end  
          res
        end

        def get_car_data
            car_data = @html.scan /<span class="attrbubble">(.*?)<\/span>/mi 
            remove_tags(car_data[0].first).split(' ') if car_data.present?
        end 

        def remove_tags(text)
          ActionView::Base.full_sanitizer.sanitize((text || '').squish)
        end  
        
    end
  end  
end
