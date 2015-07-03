module PostingConstants
	SOURCES = %w(INDEE EBAYC BKPGE CRAIG KIJIJ JBOOM HMNGS EBAYM CARSD APTSD RENTD E_BAY AUTOD CCARS AUTOC CARAU DRVAU DOMAU RESTT)
	AUSTRALIAN_SOURCES = %w(CARAU DRVAU DOMAU RESTT)
	SOURCES_NAMES = {"APTSD"=>"Apartments.com", "AUTOC"=>"autotraderclassic.com", "AUTOD"=>"autotrader.com", "BKPGE"=>"Backpage", "CARSD"=>"Cars.com", "CCARS"=>"classiccars.com", "CRAIG"=>"Craigslist", "E_BAY"=>"ebay.com", "EBAYM"=>"Ebay Motors", "HMNGS"=>"Hemmings Motor News", "INDEE"=>"Indeed", "RENTD"=>"Rent.com", "CARAU" => "carsales.com.au", "DRVAU" => "drive.com.au", "DOMAU" => "domain.com.au", "RESTT" => "RealEstate.com.au"}
  CATEGORIES = %w(AOTH APET ASUP CCNW CGRP CLNF COMM COTH CRID CVOL DDEL DTAX DTOW JACC JADM JAER JANA JANL JARC JART JAUT JBEA JBIZ JCON JCST JCUS JDES JEDU JENE JENG JENT JEVE JFIN JFNB JGIG JGOV JHEA JHOS JHUM JINS JINT JLAW JLEG JMAN JMAR JMFT JMNT JNON JOPS JOTH JPHA JPRO JPUR JQUA JREA JREC JRES JRNW JSAL JSCI JSEC JSKL JTEL JTRA JVOL JWEB JWNP MESC MFET MJOB MMSG MOTH MPNW MSTR PMSM PMSW POTH PWSM PWSW RCRE RHFR RHFS RLOT ROTH RPNS RSHR RSUB RSWP RVAC RWNT SANC SANT SAPL SAPP SBAR SBIK SBIZ SCOL SEDU SELE SFNB SFUR SGAR SGFT SHNB SHNG SIND SJWL SKID SLIT SMNM SMUS SOTH SRES SSNF STIX STOO STOY STVL SVCC SVCE SVCF SVCH SVCM SVCO SVCP SWNT VAUT VMOT VMPT VOTH VPAR ZOTH)
	CATEGORIES_NAMES = {"APET"=>"Pets", "ASUP"=>"Supplies", "AOTH"=>"Other", "CCNW"=>"Classes & Workshops", "COMM"=>"Events", "CGRP"=>"Groups", "CLNF"=>"Lost & Found", "CRID"=>"Rideshares", "CVOL"=>"Volunteers", "COTH"=>"Other", "DDEL"=>"Delivery", "DISP"=>"Dispatch", "DTAX"=>"Taxi", "DTOW"=>"Tow", "SANT"=>"Antiques", "SAPP"=>"Apparel", "SAPL"=>"Appliances", "SANC"=>"Art & Crafts", "SKID"=>"Babies & Kids", "SBAR"=>"Barters", "SBIK"=>"Bicycles", "SBIZ"=>"Businesses", "SCOL"=>"Collections", "SEDU"=>"Educational", "SELE"=>"Electronics & Photo", "SFNB"=>"Food & Beverage", "SFUR"=>"Furniture", "SGAR"=>"Garage Sales", "SGFT"=>"Gift Cards", "SHNB"=>"Health & Beauty", "SHNG"=>"Home & Garden", "SIND"=>"Industrial", "SJWL"=>"Jewelry", "SLIT"=>"Literature", "SMNM"=>"Movies & Music", "SMUS"=>"Musical Instruments", "SRES"=>"Restaurants", "SSNF"=>"Sports & Fitness", "STIX"=>"Tickets", "STOO"=>"Tools", "STOY"=>"Toys & Hobbies", "STVL"=>"Travel", "SWNT"=>"Wanted", "SOTH"=>"Other", "JACC"=>"Accounting", "JADM"=>"Administrative", "JAER"=>"Aerospace & Defense", "JANL"=>"Analyst", "JANA"=>"Animals & Agriculture", "JARC"=>"Architecture", "JART"=>"Art", "JAUT"=>"Automobile", "JBEA"=>"Beauty", "JBIZ"=>"Business Development", "JWEB"=>"Computer & Web", "JCST"=>"Construction & Facilities", "JCON"=>"Consulting", "JCUS"=>"Customer Service", "JDES"=>"Design", "JEDU"=>"Education", "JENE"=>"Energy", "JENG"=>"Engineering", "JENT"=>"Entertainment & Media", "JEVE"=>"Events", "JFIN"=>"Finance", "JFNB"=>"Food & Beverage", "JGIG"=>"Gigs", "JGOV"=>"Government", "JHEA"=>"Healthcare", "JHOS"=>"Hospitality & Travel", "JHUM"=>"Human Resources", "JMNT"=>"Installation, Maintenance & Repair", "JINS"=>"Insurance", "JINT"=>"International", "JLAW"=>"Law Enforcement", "JLEG"=>"Legal", "JMAN"=>"Management & Directorship", "JMFT"=>"Manufacturing & Mechanical", "JMAR"=>"Marketing, Advertising & Public Relations", "JNON"=>"Non-Profit", "JOPS"=>"Operations & Logistics", "JPHA"=>"Pharmaceutical", "JPRO"=>"Product, Project & Program Management", "JPUR"=>"Purchasing", "JQUA"=>"Quality Assurance", "JREA"=>"Real Estate", "JREC"=>"Recreation", "JRES"=>"Resumes", "JRNW"=>"Retail & Wholesale", "JSAL"=>"Sales", "JSCI"=>"Science", "JSEC"=>"Security", "JSKL"=>"Skilled Trade & General Labor", "JTEL"=>"Telecommunications", "JTRA"=>"Transportation", "JVOL"=>"Volunteer", "JWNP"=>"Writing & Publishing", "JOTH"=>"Other", "MESC"=>"Escorts", "MFET"=>"Fetish", "MJOB"=>"Jobs", "MMSG"=>"Massage", "MPNW"=>"Phone & Websites", "MSTR"=>"Strippers", "MOTH"=>"Other", "PMSM"=>"Men Seeking Men", "PMSW"=>"Men Seeking Women", "PWSM"=>"Women Seeking Men", "PWSW"=>"Women Seeking Women", "POTH"=>"Other", "RCRE"=>"Commercial Real Estate", "RHFR"=>"Housing For Rent", "RHFS"=>"Housing For Sale", "RSUB"=>"Housing Sublets", "RSWP"=>"Housing Swaps", "RLOT"=>"Lots & Land", "RPNS"=>"Parking & Storage", "RSHR"=>"Room Shares", "RVAC"=>"Vacation Properties", "RWNT"=>"Want Housing", "ROTH"=>"Other", "SVCC"=>"Creative", "SVCE"=>"Education", "SVCF"=>"Financial", "SVCM"=>"Health", "SVCH"=>"Household", "SVCP"=>"Professional", "SVCO"=>"Other", "ZOTH"=>"Other", "VAUT"=>"Autos", "VMOT"=>"Motorcycles", "VMPT"=>"Motorcycle Parts", "VPAR"=>"Parts", "VOTH"=>"Other"}
  CATEGORY_GROUPS = %w(AAAA CCCC DISP SSSS JJJJ MMMM PPPP RRRR SVCS ZZZZ VVVV)
	CATEGORY_GROUPS_NAMES = {"AAAA"=>"Animals", "CCCC"=>"Community", "DISP"=>"Dispatch", "SSSS"=>"For Sale", "JJJJ"=>"Jobs", "MMMM"=>"Mature", "PPPP"=>"Personals", "RRRR"=>"Real Estate", "SVCS"=>"Services", "ZZZZ"=>"Uncategorized", "VVVV"=>"Vehicles"}
  CATEGORY_RELATIONS = {
		'AAAA' => %w(APET ASUP AOTH),
		'CCCC' => %w(CCNW COMM CGRP CLNF CRID CVOL COTH),
		'DISP' => %w(DDEL DTAX DTOW),
		'SSSS' => %w(SANT SAPP SAPL SANC SKID SBAR SBIK SBIZ SCOL SEDU SELE SFNB SFUR SGAR SGFT SHNB SHNG SIND SJWL SLIT SMNM SMUS SRES SSNF STIX STOO STOY STVL SWNT SOTH),
		'JJJJ' => %w(JACC JADM JAER JANL JANA JARC JART JAUT JBEA JBIZ JWEB JCST JCON JCUS JDES JEDU JENE JENG JENT JEVE JFIN JFNB JGIG JGOV JHEA JHOS JHUM JMNT JINS JINT JLAW JLEG JMAN JMFT JMAR JNON JOPS JPHA JPRO JPUR JQUA JREA JREC JRES JRNW JSAL JSCI JSEC JSKL JTEL JTRA JVOL JWNP JOTH),
		'MMMM' => %w(MADU MESC MFET MJOB MMSG MPNW MSTR MOTH),
		'PPPP' => %w(PMSM PMSW PWSM PWSW POTH),
		'RRRR' => %w(RCRE RHFR RHFS RSUB RSWP RLOT RPNS RSHR RVAC RWNT ROTH),
		'SVCS' => %w(SVCC SVCE SVCF SVCM SVCH SVCP SVCO),
		'ZZZZ' => %w(ZOTH),
		'VVVV' => %w(VAUT VPAR VOTH VMOT VMPT)
	}
	CATEGORY_RELATIONS_REVERSE = {"APET"=>"AAAA", "ASUP"=>"AAAA", "AOTH"=>"AAAA", "CCNW"=>"CCCC", "COMM"=>"CCCC", "CGRP"=>"CCCC", "CLNF"=>"CCCC", "CRID"=>"CCCC", "CVOL"=>"CCCC", "COTH"=>"CCCC", "DDEL"=>"DISP", "DTAX"=>"DISP", "DTOW"=>"DISP", "SANT"=>"SSSS", "SAPP"=>"SSSS", "SAPL"=>"SSSS", "SANC"=>"SSSS", "SKID"=>"SSSS", "SBAR"=>"SSSS", "SBIK"=>"SSSS", "SBIZ"=>"SSSS", "SCOL"=>"SSSS", "SEDU"=>"SSSS", "SELE"=>"SSSS", "SFNB"=>"SSSS", "SFUR"=>"SSSS", "SGAR"=>"SSSS", "SGFT"=>"SSSS", "SHNB"=>"SSSS", "SHNG"=>"SSSS", "SIND"=>"SSSS", "SJWL"=>"SSSS", "SLIT"=>"SSSS", "SMNM"=>"SSSS", "SMUS"=>"SSSS", "SRES"=>"SSSS", "SSNF"=>"SSSS", "STIX"=>"SSSS", "STOO"=>"SSSS", "STOY"=>"SSSS", "STVL"=>"SSSS", "SWNT"=>"SSSS", "SOTH"=>"SSSS", "JACC"=>"JJJJ", "JADM"=>"JJJJ", "JAER"=>"JJJJ", "JANL"=>"JJJJ", "JANA"=>"JJJJ", "JARC"=>"JJJJ", "JART"=>"JJJJ", "JAUT"=>"JJJJ", "JBEA"=>"JJJJ", "JBIZ"=>"JJJJ", "JWEB"=>"JJJJ", "JCST"=>"JJJJ", "JCON"=>"JJJJ", "JCUS"=>"JJJJ", "JDES"=>"JJJJ", "JEDU"=>"JJJJ", "JENE"=>"JJJJ", "JENG"=>"JJJJ", "JENT"=>"JJJJ", "JEVE"=>"JJJJ", "JFIN"=>"JJJJ", "JFNB"=>"JJJJ", "JGIG"=>"JJJJ", "JGOV"=>"JJJJ", "JHEA"=>"JJJJ", "JHOS"=>"JJJJ", "JHUM"=>"JJJJ", "JMNT"=>"JJJJ", "JINS"=>"JJJJ", "JINT"=>"JJJJ", "JLAW"=>"JJJJ", "JLEG"=>"JJJJ", "JMAN"=>"JJJJ", "JMFT"=>"JJJJ", "JMAR"=>"JJJJ", "JNON"=>"JJJJ", "JOPS"=>"JJJJ", "JPHA"=>"JJJJ", "JPRO"=>"JJJJ", "JPUR"=>"JJJJ", "JQUA"=>"JJJJ", "JREA"=>"JJJJ", "JREC"=>"JJJJ", "JRES"=>"JJJJ", "JRNW"=>"JJJJ", "JSAL"=>"JJJJ", "JSCI"=>"JJJJ", "JSEC"=>"JJJJ", "JSKL"=>"JJJJ", "JTEL"=>"JJJJ", "JTRA"=>"JJJJ", "JVOL"=>"JJJJ", "JWNP"=>"JJJJ", "JOTH"=>"JJJJ", "MADU" => "MMMM", "MESC"=>"MMMM", "MFET"=>"MMMM", "MJOB"=>"MMMM", "MMSG"=>"MMMM", "MPNW"=>"MMMM", "MSTR"=>"MMMM", "MOTH"=>"MMMM", "PMSM"=>"PPPP", "PMSW"=>"PPPP", "PWSM"=>"PPPP", "PWSW"=>"PPPP", "POTH"=>"PPPP", "RCRE"=>"RRRR", "RHFR"=>"RRRR", "RHFS"=>"RRRR", "RSUB"=>"RRRR", "RSWP"=>"RRRR", "RLOT"=>"RRRR", "RPNS"=>"RRRR", "RSHR"=>"RRRR", "RVAC"=>"RRRR", "RWNT"=>"RRRR", "ROTH"=>"RRRR", "SVCC"=>"SVCS", "SVCE"=>"SVCS", "SVCF"=>"SVCS", "SVCM"=>"SVCS", "SVCH"=>"SVCS", "SVCP"=>"SVCS", "SVCO"=>"SVCS", "ZOTH"=>"ZZZZ", "VAUT"=>"VVVV", "VPAR"=>"VVVV", "VOTH"=>"VVVV", "VMOT" => "VVVV", "VMPT" => "VVVV", "AAAA"=>"AAAA", "CCCC"=>"CCCC", "SSSS"=>"SSSS", "JJJJ"=>"JJJJ", "MMMM"=>"MMMM", "PPPP"=>"PPPP", "RRRR"=>"RRRR", "SVCS"=>"SVCS", "ZZZZ"=>"ZZZZ", "VVVV"=>"VVVV"}
	STATUSES = %w(registered for_sale for_hire for_rent wanted lost stolen found)
	CREATE_ONE_POSTING_TIME = 0.004

	DEFAULT_RETVALS = %w(id source category location external_id external_url heading timestamp)
	ALLOWED_RETVALS = %w(id account_id source category category_group location external_id external_url heading body
 html timestamp expires language price currency images annotations status immortal deleted flagged_status state
 origin_ip_address transit_ip_address geolocation_status)

	SOURCES_FOR_PARSING = %w(REMLS EBAYM HMMGS)
	STATES = %w(available unavailable expired)
	FLAGGED_STATUSES = [
											{value: 0, description: "The posting has never been flagged"},
											{value: 1, description: "The posting has been flagged by a user"},
											{value: 2, description: "The flagged status was overruled"}
	]

	REMLS_FIELDS = %w(abbreviated active address address_normalized agent1_address agent1_comments agent1_dontdisplay agent1_image agent1_name agent1_points agent1_summary agent1_url agent_address agent_comments agent_dontdisplay agent_image agent_name agent_points agent_summary agent_url apn area baths beds buyer_agent_id buyer_office_id buyer_office_name city construction cooling county crawled crawler_id created display_on_web elementary_school exterior_features finished_sqft fireplace_features garage_qty garage_type half_baths heating heating_cooling high_school id image_updated interior_features is_estimate is_foreclosure is_shortsale junior_high_school latitude listing_agent_1_id listing_agent_name listing_agent_primary_id listing_date listing_date_unconfident listing_office_1_id listing_office_name listing_office_primary_id listing_parent_type listing_refresh_date listing_type listing_type_id listing_type_parent_id longitude lot_size middle_school mls_feed_id mls_id neighborhood num_photos off_market_date off_market_date_unconfident office1_address office1_name office1_slogen office1_url office_address office_name office_slogen office_url photo_urls previous_price price property_features public_remarks public_remarks_summary quarter_bath realtor_datasource_id realtor_id realtor_mpr_id realtor_source_abbreviation realtor_source_listing_id redfin_id redfin_mls_status_id redfin_source_id reduced region region_city_id region_id region_neighborhood_id region_state_id region_zip_id roof school_district sold_on square_feet start_price state status stories style subdivision three_quarter_bath type updated views water_sewage year_built zip)

	CRAIG_STATUSES_BY_CAT = {
		'boo' => 'for_sale', 'pta' => 'for_sale', 'apa' => 'for_sale', 'rea' => 'for_sale', 'hsw' => 'for_sale', 'tla' => 'for_rent', 'taa' => 'for_rent', 'cta' => 'for_rent', 'mca' => 'for_rent', 'rva' => 'for_rent', 'cal' => 'for_hire', 'ara' => 'for_hire', 'ata' => 'for_hire', 'ppa' => 'for_hire', 'cla' => 'for_hire', 'bia' => 'for_hire', 'bfa' => 'for_hire', 'cba' => 'for_hire', 'sya' => 'for_hire', 'moa' => 'for_hire', 'ela' => 'for_hire', 'pha' => 'for_hire', 'vga' => 'for_hire', 'fua' => 'for_hire', 'haa' => 'for_hire', 'gra' => 'for_hire', 'hsa' => 'for_hire', 'maa' => 'for_hire', 'jwa' => 'for_hire', 'baa' => 'for_hire', 'bka' => 'for_hire', 'ema' => 'for_hire', 'msa' => 'for_hire', 'foa' => 'for_hire', 'sga' => 'for_hire', 'tia' => 'for_hire',	'pet' =>'for_sale', 'laf' =>'lost / stolen / found', 'eve' =>'registered', 'cls' =>'registered', 'act' =>'registered', 'com' =>'registered', 'grp' =>'registered', 'rid' =>'for_hire', 'vnn' =>'registered', 'pol' =>'registered', 'vol' =>'for_hire', 'ats' =>'for_hire', 'muc' =>'for_hire', 'kid' =>'for_hire', 'gms' =>'registered', 'ard' =>'for_sale', 'art' =>'for_sale', 'atd' =>'for_sale', 'atq' =>'for_sale', 'ppd' =>'for_sale', 'app' =>'for_sale', 'cld' =>'for_sale', 'clo' =>'for_sale', 'bar' =>'for_sale', 'bik' =>'for_sale', 'bid' =>'for_sale', 'bfd' =>'for_sale', 'bfs' =>'for_sale', 'cbd' =>'for_sale', 'clt' =>'for_sale', 'syd' =>'for_sale', 'sys' =>'for_sale', 'mob' =>'for_sale', 'mod' =>'for_sale', 'eld' =>'for_sale', 'ele' =>'for_sale', 'phd' =>'for_sale', 'pho' =>'for_sale', 'vgm' =>'for_sale', 'vgd' =>'for_sale', 'fud' =>'for_sale', 'fuo' =>'for_sale', 'hab' =>'for_sale', 'had' =>'for_sale', 'grq' =>'for_sale', 'grd' =>'for_sale', 'hsd' =>'for_sale', 'hsh' =>'for_sale', 'mad' =>'for_sale', 'mat' =>'for_sale', 'jwd' =>'for_sale', 'jwl' =>'for_sale', 'bad' =>'for_sale', 'bab' =>'for_sale', 'bkd' =>'for_sale', 'bks' =>'for_sale', 'emq' =>'for_sale', 'emd' =>'for_sale', 'msd' =>'for_sale', 'msg' =>'for_sale', 'fod' =>'for_sale', 'for' =>'for_sale', 'zip' =>'for_sale', 'sgd' =>'for_sale', 'spo' =>'for_sale', 'tid' =>'for_sale', 'tix' =>'for_sale', 'tld' =>'for_sale', 'tls' =>'for_sale', 'tad' =>'for_sale', 'tag' =>'for_sale', 'wan' =>'wanted', 'ctd' =>'for_sale', 'cto' =>'for_sale', 'mcd' =>'for_sale', 'mcy' =>'for_sale', 'rvs' =>'for_sale', 'rvd' =>'for_sale', 'bod' =>'for_sale', 'boa' =>'for_sale', 'ptd' =>'for_sale', 'pts' =>'for_sale', 'crg' =>'for_hire', 'cwg' =>'for_hire', 'dmg' =>'for_hire', 'evg' =>'for_hire', 'lbg' =>'for_hire', 'tlg' =>'for_hire', 'wrg' =>'for_hire', 'cpg' =>'for_hire', 'off' =>'for_rent', 'nfa' =>'for_rent', 'fee' =>'for_rent', 'nfb' =>'for_rent', 'abo' =>'for_rent', 'aiv' =>'for_rent', 'reb' =>'for_sale', 'reo' =>'for_sale', 'prk' =>'for_rent', 'roo' =>'for_rent', 'sbw' =>'for_rent', 'sub' =>'for_rent', 'swp' =>'for_rent', 'vac' =>'for_rent', 'hou' =>'wanted', 'rew' =>'wanted', 'sha' =>'wanted', 'ofc' =>'for_hire', 'spa' =>'for_hire', 'sls' =>'for_hire', 'csr' =>'for_hire', 'tch' =>'for_hire', 'med' =>'for_hire', 'edu' =>'for_hire', 'egr' =>'for_hire', 'tfr' =>'for_hire', 'acc' =>'for_hire', 'fbh' =>'for_hire', 'gov' =>'for_hire', 'hea' =>'for_hire', 'hum' =>'for_hire', 'lgl' =>'for_hire', 'bus' =>'for_hire', 'mar' =>'for_hire', 'mnu' =>'for_hire', 'npo' =>'for_hire', 'etc' =>'for_hire', 'rej' =>'for_hire', 'ret' =>'for_hire', 'sci' =>'for_hire', 'sec' =>'for_hire', 'lab' =>'for_hire', 'trd' =>'for_hire', 'trp' =>'for_hire', 'eng' =>'for_hire', 'sof' =>'for_hire', 'sad' =>'for_hire', 'web' =>'for_hire', 'wri' =>'for_hire', 'rnr' =>'registered', 'cas' =>'registered', 'm4m' =>'registered', 'msr' =>'registered', 'mis' =>'registered', 'm4w' =>'registered', 'w4m' =>'registered', 'stp' =>'registered', 'w4w' =>'registered', 'res' =>'for_hire', 'trv' =>'for_hire', 'wet' =>'for_hire', 'lss' =>'for_hire', 'fns' =>'for_hire', 'fgs' =>'for_hire', 'hss' =>'for_hire', 'bts' =>'for_hire', 'ths' =>'for_hire', 'thp' =>'for_hire', 'aos' =>'for_hire', 'cps' =>'for_hire', 'cys' =>'for_hire', 'evs' =>'for_hire', 'lbs' =>'for_hire', 'lgs' =>'for_hire', 'mas' =>'for_hire', 'pas' =>'for_hire', 'rts' =>'for_hire', 'sks' =>'for_hire', 'biz' =>'for_hire', 'crs' =>'for_hire'
	}

  COLUMNS_WIDTHS = {"source"=>5, "category"=>4, "external_id"=>20, "external_url"=>385, "heading"=>155, "language"=>2, "currency"=>3, "status"=>10, "category_group"=>4, "country"=>3, "state"=>6, "metro"=>7, "region"=>11, "county"=>10, "city"=>12, "locality"=>12, "zipcode"=>9, "account_id"=>1, "posting_state"=>9, "origin_ip_address"=>15, "transit_ip_address"=>15, "formatted_address"=>255}

	FIRST_VOLUME = if Rails.env.production?
		421
	elsif Rails.env.development?
		0
  else
    0
	end

	LAST_VOLUME = if Rails.env.production?
		603
	elsif Rails.env.development?
		0
  else
    0
	end

	URL = if Rails.env.production?
		'http://polling.3taps.com/'
	elsif Rails.env.staging?
		'staging-posting.3taps.com'
	elsif Rails.env.development?
		'localhost:3000'
	end

	VOLUME_SIZE = 1_000_000

  #MCR --- metro-category-report
  MCR_CODES = %w(SAN SFO LAX SPO AUT LAS SEA BOI CHI MIA DAL WAS PHI BOS DEN HOU CHS ATL POR CTN SAT PHX JAF IDO CUO DET ELP MEM NAS LOU MIW OKL TUC FRS SAC KAN ABU VIR TLS CLE MIN NEO TPA HON PIT CIN BUF ORL MAW NYM STL TOL BIR JCS CAC WAC MOG MCN SVN ALG BRU AUG COG TLH DOT TER CHP EVV GSO FAA CLV TWI LIM GEM COO RAL OMA SAR WIK BAK COP LEK ANC STC LIN FOW LRE LUB REN BAO RON RCV DES MOD FAN SHR LIT AMA MOI GRR SLT HUT KNO BRX CHT PTT SRO SIF EUG SLS SRA DAY ROF FOC SYR CAV SAV MCL KIN CLS CER TOP VIS GAI CRS HRT LFL MDT BEU ATG ABI SRI PRO PEO LNS CIM ALL WIM FAG RCM ALN BNI CAO CHB CHC EUR FAM FRR HAP LSC PIF PUE RUT SRC UKI YOR)
  MCR_CATEGORIES = %w(PMSW PWSM APET SFUR SELE SOTH VAUT VOTH VMOT SHNG SKID SAPP SSNF SANT STOO SBIK SJWL SGAR SBAR STIX SWNT SVCH COTH)


  def self.check_updates_for(constant)
    case constant
      when :categories
        UpdatesCheck.check_categories

      when :category_groups
        UpdatesCheck.check_groups

      else
        raise "I do not know constant updates check method for #{ constant }"
    end
  end

  class UpdatesCheck
    class << self
      def diff(array1, array2)
        {
            remove: (array1 - array2),
            add: (array2 - array1)
        }
      end

      def check_categories
        categories_from_constant = PostingConstants::CATEGORIES
        response = JSON.parse RestClient.get('http://reference.3taps.com/categories?auth_token=52583033c5aa2786f93ea4d862b74120')

        categories_from_reference = response['categories'].map { |c| c['code'] }
        categories_changed = (categories_from_constant != categories_from_reference)

        difference = diff(categories_from_constant, categories_from_reference)

        return if difference[:remove].blank? and difference[:add].blank?

        text = <<-MESSAGE
      Categories were changed.<br />
      Need to be removed: #{ difference[:remove] }<br />
      Need to be added: #{ difference[:add] }<br />
        MESSAGE

        if categories_changed && categories_from_constant.present?
          if Rails.env.development?
            puts text
          else
            NotificationMailer.notice(text).deliver!
          end
        end
      end

      def check_groups
        groups_from_constant = PostingConstants::CATEGORY_GROUPS
        response = JSON.parse RestClient.get('http://reference.3taps.com/category_groups?auth_token=52583033c5aa2786f93ea4d862b74120')

        groups_from_reference = response['category_groups'].map { |c| c['code'] }
        groups_changed = (groups_from_constant != groups_from_reference)

        difference = diff(groups_from_constant, groups_from_reference)

        return if difference[:remove].blank? and difference[:add].blank?

        text = <<-MESSAGE
      Category groups were changed.<br />
      Need to be removed: #{ difference[:remove] }<br />
      Need to be added: #{ difference[:add] }<br />
        MESSAGE

        if groups_changed && groups_from_constant.present?
          if Rails.env.development?
            puts text
          else
            NotificationMailer.notice(text).deliver!
          end
        end
      end
    end
  end

  if Rails.env.production?
    TRANSIT_IPS = ["108.175.160.26", "108.175.162.18"]
  else
    TRANSIT_IPS = ["109.251.150.152",  "108.175.169.4", "127.0.0.1"]
  end

  TRACK_CARMAKER_SOURCES = %w(HMNGS EBAYM CARSD AUTOD CCARS)
end


