FactoryGirl.define do
  factory :posting do
    source 'JBOOM'
    category 'APET'
    external_id '123'
    status 'for_sale'
    timestamp { DateTime.now.to_i.to_s }
    heading 'some heding'
    location {{city: 'New York', state: 'CA'}}
  end

  factory :remls_posting, parent: :posting do
    source 'REMLS'
  end

  factory :craig_posting, parent: :posting do
    source 'CRAIG'
  end
end
