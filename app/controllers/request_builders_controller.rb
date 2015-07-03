class RequestBuildersController < ApplicationController
  REQUEST_BUILDER_API_KEY = '93418186281e8a964d707433b43a1485'

  layout 'request_builder'

  before_action :set_api_key

  def locations
  end

  def polling
    @groups = {"AAAA"=>{"name"=>"Animals", "categories"=>[{"code"=>"APET", "name"=>"Pets"}, {"code"=>"ASUP", "name"=>"Supplies"}, {"code"=>"AOTH", "name"=>"Other"}]}, "CCCC"=>{"name"=>"Community", "categories"=>[{"code"=>"CCNW", "name"=>"Classes & Workshops"}, {"code"=>"COMM", "name"=>"Events"}, {"code"=>"CGRP", "name"=>"Groups"}, {"code"=>"CLNF", "name"=>"Lost & Found"}, {"code"=>"CRID", "name"=>"Rideshares"}, {"code"=>"CVOL", "name"=>"Volunteers"}, {"code"=>"COTH", "name"=>"Other"}]}, "DISP"=>{"name"=>"Dispatch", "categories"=>[{"code"=>"DDEL", "name"=>"Delivery"}, {"code"=>"DTAX", "name"=>"Taxi"}, {"code"=>"DTOW", "name"=>"Tow"}]}, "SSSS"=>{"name"=>"For Sale", "categories"=>[{"code"=>"SANT", "name"=>"Antiques"}, {"code"=>"SAPP", "name"=>"Apparel"}, {"code"=>"SAPL", "name"=>"Appliances"}, {"code"=>"SANC", "name"=>"Art & Crafts"}, {"code"=>"SKID", "name"=>"Babies & Kids"}, {"code"=>"SBAR", "name"=>"Barters"}, {"code"=>"SBIK", "name"=>"Bicycles"}, {"code"=>"SBIZ", "name"=>"Businesses"}, {"code"=>"SCOL", "name"=>"Collections"}, {"code"=>"SEDU", "name"=>"Educational"}, {"code"=>"SELE", "name"=>"Electronics & Photo"}, {"code"=>"SFNB", "name"=>"Food & Beverage"}, {"code"=>"SFUR", "name"=>"Furniture"}, {"code"=>"SGAR", "name"=>"Garage Sales"}, {"code"=>"SGFT", "name"=>"Gift Cards"}, {"code"=>"SHNB", "name"=>"Health & Beauty"}, {"code"=>"SHNG", "name"=>"Home & Garden"}, {"code"=>"SIND", "name"=>"Industrial"}, {"code"=>"SJWL", "name"=>"Jewelry"}, {"code"=>"SLIT", "name"=>"Literature"}, {"code"=>"SMNM", "name"=>"Movies & Music"}, {"code"=>"SMUS", "name"=>"Musical Instruments"}, {"code"=>"SRES", "name"=>"Restaurants"}, {"code"=>"SSNF", "name"=>"Sports & Fitness"}, {"code"=>"STIX", "name"=>"Tickets"}, {"code"=>"STOO", "name"=>"Tools"}, {"code"=>"STOY", "name"=>"Toys & Hobbies"}, {"code"=>"STVL", "name"=>"Travel"}, {"code"=>"SWNT", "name"=>"Wanted"}, {"code"=>"SOTH", "name"=>"Other"}]}, "JJJJ"=>{"name"=>"Jobs", "categories"=>[{"code"=>"JACC", "name"=>"Accounting"}, {"code"=>"JADM", "name"=>"Administrative"}, {"code"=>"JAER", "name"=>"Aerospace & Defense"}, {"code"=>"JANL", "name"=>"Analyst"}, {"code"=>"JANA", "name"=>"Animals & Agriculture"}, {"code"=>"JARC", "name"=>"Architecture"}, {"code"=>"JART", "name"=>"Art"}, {"code"=>"JAUT", "name"=>"Automobile"}, {"code"=>"JBEA", "name"=>"Beauty"}, {"code"=>"JBIZ", "name"=>"Business Development"}, {"code"=>"JWEB", "name"=>"Computer & Web"}, {"code"=>"JCST", "name"=>"Construction & Facilities"}, {"code"=>"JCON", "name"=>"Consulting"}, {"code"=>"JCUS", "name"=>"Customer Service"}, {"code"=>"JDES", "name"=>"Design"}, {"code"=>"JEDU", "name"=>"Education"}, {"code"=>"JENE", "name"=>"Energy"}, {"code"=>"JENG", "name"=>"Engineering"}, {"code"=>"JENT", "name"=>"Entertainment & Media"}, {"code"=>"JEVE", "name"=>"Events"}, {"code"=>"JFIN", "name"=>"Finance"}, {"code"=>"JFNB", "name"=>"Food & Beverage"}, {"code"=>"JGIG", "name"=>"Gigs"}, {"code"=>"JGOV", "name"=>"Government"}, {"code"=>"JHEA", "name"=>"Healthcare"}, {"code"=>"JHOS", "name"=>"Hospitality & Travel"}, {"code"=>"JHUM", "name"=>"Human Resources"}, {"code"=>"JMNT", "name"=>"Installation, Maintenance & Repair"}, {"code"=>"JINS", "name"=>"Insurance"}, {"code"=>"JINT", "name"=>"International"}, {"code"=>"JLAW", "name"=>"Law Enforcement"}, {"code"=>"JLEG", "name"=>"Legal"}, {"code"=>"JMAN", "name"=>"Management & Directorship"}, {"code"=>"JMFT", "name"=>"Manufacturing & Mechanical"}, {"code"=>"JMAR", "name"=>"Marketing, Advertising & Public Relations"}, {"code"=>"JNON", "name"=>"Non-Profit"}, {"code"=>"JOPS", "name"=>"Operations & Logistics"}, {"code"=>"JPHA", "name"=>"Pharmaceutical"}, {"code"=>"JPRO", "name"=>"Product, Project & Program Management"}, {"code"=>"JPUR", "name"=>"Purchasing"}, {"code"=>"JQUA", "name"=>"Quality Assurance"}, {"code"=>"JREA", "name"=>"Real Estate"}, {"code"=>"JREC", "name"=>"Recreation"}, {"code"=>"JRES", "name"=>"Resumes"}, {"code"=>"JRNW", "name"=>"Retail & Wholesale"}, {"code"=>"JSAL", "name"=>"Sales"}, {"code"=>"JSCI", "name"=>"Science"}, {"code"=>"JSEC", "name"=>"Security"}, {"code"=>"JSKL", "name"=>"Skilled Trade & General Labor"}, {"code"=>"JTEL", "name"=>"Telecommunications"}, {"code"=>"JTRA", "name"=>"Transportation"}, {"code"=>"JVOL", "name"=>"Volunteer"}, {"code"=>"JWNP", "name"=>"Writing & Publishing"}, {"code"=>"JOTH", "name"=>"Other"}]}, "MMMM"=>{"name"=>"Mature", "categories"=>[{"code"=>"MESC", "name"=>"Escorts"}, {"code"=>"MFET", "name"=>"Fetish"}, {"code"=>"MJOB", "name"=>"Jobs"}, {"code"=>"MMSG", "name"=>"Massage"}, {"code"=>"MPNW", "name"=>"Phone & Websites"}, {"code"=>"MSTR", "name"=>"Strippers"}, {"code"=>"MOTH", "name"=>"Other"}]}, "PPPP"=>{"name"=>"Personals", "categories"=>[{"code"=>"PMSM", "name"=>"Men Seeking Men"}, {"code"=>"PMSW", "name"=>"Men Seeking Women"}, {"code"=>"PWSM", "name"=>"Women Seeking Men"}, {"code"=>"PWSW", "name"=>"Women Seeking Women"}, {"code"=>"POTH", "name"=>"Other"}]}, "RRRR"=>{"name"=>"Real Estate", "categories"=>[{"code"=>"RCRE", "name"=>"Commercial Real Estate"}, {"code"=>"RHFR", "name"=>"Housing For Rent"}, {"code"=>"RHFS", "name"=>"Housing For Sale"}, {"code"=>"RSUB", "name"=>"Housing Sublets"}, {"code"=>"RSWP", "name"=>"Housing Swaps"}, {"code"=>"RLOT", "name"=>"Lots & Land"}, {"code"=>"RPNS", "name"=>"Parking & Storage"}, {"code"=>"RSHR", "name"=>"Room Shares"}, {"code"=>"RVAC", "name"=>"Vacation Properties"}, {"code"=>"RWNT", "name"=>"Want Housing"}, {"code"=>"ROTH", "name"=>"Other"}]}, "SVCS"=>{"name"=>"Services", "categories"=>[{"code"=>"SVCC", "name"=>"Creative"}, {"code"=>"SVCE", "name"=>"Education"}, {"code"=>"SVCF", "name"=>"Financial"}, {"code"=>"SVCM", "name"=>"Health"}, {"code"=>"SVCH", "name"=>"Household"}, {"code"=>"SVCP", "name"=>"Professional"}, {"code"=>"SVCO", "name"=>"Other"}]}, "ZZZZ"=>{"name"=>"Uncategorized", "categories"=>[{"code"=>"ZOTH", "name"=>"Other"}]}, "VVVV"=>{"name"=>"Vehicles", "categories"=>[{"code"=>"VAUT", "name"=>"Autos"}, {"code"=>"VMOT", "name"=>"Motorcycles"}, {"code"=>"VMPT", "name"=>"Motorcycle Parts"}, {"code"=>"VPAR", "name"=>"Parts"}, {"code"=>"VOTH", "name"=>"Other"}]}}
  end

  def reference_api_request
    url = "http://reference.3taps.com/locations?auth_token=#{ REQUEST_BUILDER_API_KEY }&#{ request.GET.map {|k,v| "#{k}=#{v}"}.join '&' }"
    ajax_response = RestClient.get url

    render json: ajax_response
  end

  private

  def set_api_key
    @api_key = REQUEST_BUILDER_API_KEY
  end
end