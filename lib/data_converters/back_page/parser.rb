module DataConverters
  module BackPage
    class Parser
      attr_accessor :xml_doc, :bkpge_category

      def initialize(xml_doc)
        @xml_doc = xml_doc
      end

      def get_postings
        postings = @xml_doc.scan /(<listing>.*?<\/listing>)/mi
        postings.map{ |item| "<?xml version=\"1.0\" encoding=\"utf-8\"?>"+item.first }
      end 

      def parse_posting(xml)
        parse(xml) if xml
      end

      def timestamp(posting)
        doc = Nokogiri::XML(posting)
        listing = doc.xpath("//listing")
        timestamp = listing.xpath("create_time").text.to_i
      end

      def parse(posting)
        if posting
          doc = Nokogiri::XML(posting)
          listing = doc.xpath("//listing")
          images = []
          timestamp = listing.xpath("create_time").text.to_i
          external_id = listing.xpath("id").text
          bckpg_category = listing.xpath("category").text
          @bkpge_category = bckpg_category
          external_url = listing.xpath("url").text
          expires = listing.xpath("expire_time").text
          body = listing.xpath("description").text
          heading = listing.xpath("title").text
          image_url = listing.xpath("image_url").text
          images << image_url.blank? ? {} : {full: image_url}
          #location
          address = listing.xpath("location//address").text
          neighbourhood = listing.xpath("location//neighbourhood").text
          city = listing.xpath("location//city").text
          state = listing.xpath("location//state").text
          country = listing.xpath("location//country_code").text
          zipcode = listing.xpath("location//zip_code").text
          formatted_address = []
          formatted_address << address.titleize       if address.present?
          formatted_address << neighbourhood.titleize if neighbourhood.present? 
          formatted_address << city.titleize          if city.present? 
          formatted_address << state.upcase           if state.present?
          formatted_address << country.upcase         if country.present?
          formatted_address << zipcode                if zipcode.present?
          { timestamp: timestamp,
            source: "BKPGE",
            external_id: external_id,
            category: category(bckpg_category),
            external_url: external_url,
            expires: expires,
            heading: heading,
            body: body,
            images: images,
            annotations: {},
            city: city,
            country: country,
            state: state,
            zipcode: zipcode,
            formatted_address: formatted_address.join(", ") 
          }
        end
      end  

      private

      def category(bckpg_caterory)
        cat = nil
        if bckpg_caterory
          CategoriesData::RELATION_CHILD_CATEGORY_TO_FULLSUFFIX.each do |key,value|
            if value.include? bckpg_caterory 
              cat = key
            end
          end
        end
        cat
      end  

    end
  end  
end