# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :converter do
      source 'OODLE'
      use_accept_status  false
      convert_status  false
      use_reject_status false

      use_accept_state  false
      convert_state  false
      use_reject_state  false

      use_accept_flagged_status  false
      convert_flagged_status  false
      use_reject_flagged_status  false

      use_accept_category_group false
      use_reject_category_group false 
      
      use_geolocation_module true

      factory :ebaym_converter do
        source 'EBAYM'
        use_accept_category_group true
        accept_category_group ['VVVV']
      end
      
      factory :accept_status_converter do
        use_accept_status true
        accept_status ['for_sale'] 
      end

      factory :convert_status_converter do
        convert_status true
        status 'for_sale' 
        convert_status_values ['for_rent']
      end      

      factory :reject_status_converter do
        use_reject_status true
        reject_status ['for_sale'] 
      end

      factory :accept_state_converter do
        use_accept_state true
        accept_state ['available']
      end 

      factory :convert_state_converter do
        convert_state true
        state 'available' 
        convert_state_values ['expired']
      end  

      factory :reject_state_converter do
        use_reject_state true
        reject_state ['available']
      end

      factory :accept_flagged_status_converter do
        use_accept_flagged_status true
        accept_flagged_status [1] 
      end

      factory :convert_flagged_status_converter do
        convert_flagged_status true
        flagged_status '1' 
        convert_flagged_status_values [0]
      end 

      factory :reject_flagged_status_converter do
        use_reject_flagged_status true
        reject_flagged_status [1] 
      end

      factory :accept_category_converter do
        use_accept_category true
        accept_category ['VAUT']
      end

      factory :reject_category_converter do
        use_reject_category true
        reject_category ['VAUT']
      end 

      factory :accept_category_group_converter do
        use_accept_category_group true
        accept_category_group ['RHFR']
      end

      factory :reject_category_group_converter do
        use_reject_category_group true
        reject_category_group ['VVVV']
      end
  
  end
    
end