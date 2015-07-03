require "spec_helper"

describe PostingsController do
  let(:controller) { PostingsController.new }
  before do
    PostingsController.any_instance.stub(:authorize_in_3taps => nil)
  end

  describe "#authorize_in_3taps" do
    before do
      PostingsController.any_instance.unstub(:authorize_in_3taps)
    end

    context 'user exists' do
      it 'pass authorization' do
        env_for_strong_params(auth_token: 123)
        get :anchor
        expect(response.body).to eq({success: false, error: 'auth_token is required, timestamp is required'}.to_json)
      end
    end

    # NOTICE: disabled for test purposes
    #context 'user doesnnt exists' do
    #it 'doesnt pass authorization' do
    #env_for_strong_params(auth_token: 123)
    #get :anchor
    #expect(response.body).to eq({success: false, error: 'auth_token is invalid'}.to_json)
    #end
    #end
  end

  describe "#posting_params" do
    context 'root attributes' do
      it 'permits auth_token' do
        env_for_strong_params(stub_hash_from_array([:auth_token]))

        filtered_params = controller.instance_eval { posting_params }
        expect(filtered_params).to include(:auth_token)
      end

      it 'permits postings' do
        env_for_strong_params(stub_hash_from_array([:postings]))

        filtered_params = controller.instance_eval { posting_params }
        expect(filtered_params).to include(:postings)
      end

      it 'doesnt permits other attrs' do
        env_for_strong_params(stub_hash_from_array([:other_attr]))

        filtered_params = controller.instance_eval { posting_params }
        expect(filtered_params).to_not include(:other_attr)
      end
    end

    context 'posting attributes' do
      let(:posting_mask) { [:source, :category, :location, :external_id, :external_url, :heading, :body, :html, :timestamp, :expires, :language, :price, :currency, :annotations, :status, :flagged, :deleted, :immortal, :images] }

      context 'for multiple posting' do
        it 'allows perpermits allowed' do
          env_for_strong_params({:postings => [stub_hash_from_array(posting_mask)]})

          filtered_params = controller.instance_eval { posting_params }
          expect(filtered_params[:postings][0].keys).to eq(posting_mask.map(&:to_s))
        end

        it 'doesnt permit other' do
          env_for_strong_params({:postings => [stub_hash_from_array([:other_attr])]})

          filtered_params = controller.instance_eval { posting_params }
          expect(filtered_params[:postings][0]).to_not include('other_attr')
        end
      end

      context 'for single postings (converted to multiple postings params)' do
        it 'permits allowed' do
          env_for_strong_params({:posting => stub_hash_from_array(posting_mask)})

          filtered_params = controller.instance_eval { posting_params }
          expect(filtered_params[:postings][0].keys).to eq(posting_mask.map(&:to_s))
        end

        it 'doesnt permit other' do
          env_for_strong_params({:posting => stub_hash_from_array([:other_attr])})

          filtered_params = controller.instance_eval { posting_params }
          expect(filtered_params[:postings][0]).to_not include('other_attr')
        end
      end
    end

    context 'location attributes' do
      let(:location_mask) { [:lat, :long, :accuracy, :bounds, :country, :state, :metro, :region, :county, :city, :locality, :zipcode] }

      it 'permits allowed' do
        env_for_strong_params({:postings => [:location => stub_hash_from_array(location_mask)]})

        filtered_params = controller.instance_eval { posting_params }
        expect(filtered_params[:postings][0][:location].keys).to eq(location_mask.map(&:to_s))
      end

      it 'doesnt permit other' do
        env_for_strong_params({:postings => [:location => stub_hash_from_array([:other_attr])]})

        filtered_params = controller.instance_eval { posting_params }
        expect(filtered_params[:postings][0][:location]).to_not include('other_attr')
      end
    end

    context 'images attributes' do
      let(:images) { [:full, :full_width, :full_height, :thumbnail, :thumbnail_width, :thumbnail_height] }

      it 'permits allowed' do
        env_for_strong_params({:postings => [{:images => stub_hash_from_array(images)}]})

        filtered_params = controller.instance_eval { posting_params }
        expect(filtered_params[:postings][0][:images].keys).to eq(images.map(&:to_s))
      end

      it 'doesnt permit other' do
        env_for_strong_params({:postings => [:images => stub_hash_from_array([:other_attr])]})

        filtered_params = controller.instance_eval { posting_params }
        expect(filtered_params[:postings][0][:images]).to_not include('other_attr')
      end
    end

    context 'bounds attributes' do
      let(:bounds) { [:min_lat, :max_lat, :min_long, :max_long] }

      it 'permits allowed' do
        env_for_strong_params({:postings => [{:location => {:bounds => stub_hash_from_array(bounds)}}]})

        filtered_params = controller.instance_eval { posting_params }
        expect(filtered_params[:postings][0][:location][:bounds].keys).to eq(bounds.map(&:to_s))
      end

      it 'doesnt permit other' do
        env_for_strong_params({:postings => [{:location => {:bounds => stub_hash_from_array([:other_attr])}}]})

        filtered_params = controller.instance_eval { posting_params }
        expect(filtered_params[:postings][0][:location][:bounds]).to_not include('other_attr')
      end
    end
  end

  describe "POST #create" do
    context "EBAYM processor used" do
      it "instantiates the right class" do
        EbaymPostingProcessor.should_receive(:new)
        post :create, {postings: [{source: "EBAYM", category: "VAUT", category_group: "VVVV", location: {city: "Astoria", state: "NY", country: "USA", formatted_address: "Astoria, NY"}, external_id: "1590589", external_url: "http://www.hemmings.com/classifieds/dealer/jaguar/c_type/1590589.html", heading: "1965 Jaguar C-Type", body: "<a href=\"http://www.hemmings.com/classifieds/dealer/jaguar/c_type/1590589.html?refer=rss\"><img src=\"http://assets.hemmings.com/uimage/17409359-425-0.jpg\" title=\"1965 Jaguar C-Type\"></a>1965 Jaguar C-Type - $69,500 - Astoria, NY - <p>\n\t<strong>This Jaguar C-Type Replica runs a drives very well. It&#39;s a very honest example in driver condition. It comes with it&#39;s tonneau cover and spare wheel. This would be a very fun collectible to drive. Here&#39;s your chance to own the legenday C-Type for only $69,500</strong></p>", timestamp: 1379548805, expires: 1382157615, language: "EN", price: 69500, currency: "USD", images: [{full: "http : // assets.hemmings.com/uimage/17409359-425-0.jpg "}], annotations: { :"Make" => "Jaguar", :"Model" => "C Type", :"Year" => "1965"}, status: "offered"}]}
      end
    end
  end

  describe "GET #anchor" do
    context 'validation params is failed' do
      it 'shows error' do
        PostingsController.any_instance.stub(:validate_anchor_params => 'some error')
        get :anchor, {}
        expect(response.body).to eq({success: false, error: 'some error'}.to_json)
      end
    end

    context 'params valid but anchor was not found' do
      it 'shows error' do
        PostingsController.any_instance.stub(:validate_anchor_params) { [] }
        PostingsController.any_instance.stub(:try_database_for_anchor) { nil }
        get :anchor, {auth_token: 'qwerty', timestamp: '1'}
        expect(response.body).to eq({success: false, error: 'No anchor found'}.to_json)
      end
    end

    context 'anchor was found' do
      before do
        FactoryGirl.create :posting
        PostingsController.any_instance.stub(:anchor_params => { timestamp: (DateTime.now.utc.to_i + 10).to_s })
        PostingsController.any_instance.stub(:validate_anchor_params => nil)
        PostingsController.any_instance.stub(:try_database_for_anchor => 666666666)
      end

      it 'shows response with anchor' do
        get :anchor, {auth_token: 'qwerty', timestamp: '123456'}
        expect(response.body).to eq({success: true, anchor: 666666666}.to_json)
      end
    end
  end

  describe "GET #poll" do
    context 'validation params is failed' do
      before do
        PostingsController.any_instance.stub(:validate_poll_params => 'some error')
      end

      it 'shows error' do
        get :poll, {}
        expect(response.body).to eq({success: false, error: 'some error'}.to_json)
      end
    end

    context 'params valid' do
      before do
        PostingsController.any_instance.stub(:validate_poll_params => [])
        Posting.stub(:search_postings => [])
        PostingsController.any_instance.stub(:convert_to_response_form => {response: 'some response'})
      end

      it 'shows valid response' do
        get :poll, {}
        expect(response.body).to eq({response: 'some response'}.to_json)
      end
    end
  end

  describe "#poll_params" do
    context 'forbidden attributes present' do
      it 'forbids forbidden attributes' do
        env_for_strong_params(stub_hash_from_array([:region, :county, :city, :locality, :zipcode, :status, :retvals, :forbidden_attribute]))

        filtered_params = controller.instance_eval { poll_params }

        expect(filtered_params).to include(:region, :county, :city, :locality, :zipcode, :status, :retvals)
        expect(filtered_params).to_not include(:forbidden_attribute)
      end
    end

    context 'all attributes are allowed' do
      it 'permits all attributes' do
        env_for_strong_params(stub_hash_from_array([:auth_token, :anchor, :source, :category_group, :category, :country, :state, :metro, :region, :county, :city, :locality, :zipcode, :status, :retvals]))

        filtered_params = controller.instance_eval { poll_params }
        expect(filtered_params).to include(:auth_token, :anchor, :source, :category_group, :category, :country, :state, :metro, :region, :county, :city, :locality, :zipcode, :status, :retvals)
      end
    end

    context 'retvals is absent' do
      it 'retvals get default value' do
        env_for_strong_params(stub_hash_from_array([:auth_token, :anchor, :source, :category_group, :category, :country, :state, :metro, :region, :county, :city, :locality, :zipcode, :status]))

        filtered_params = controller.instance_eval { poll_params }
        expect(filtered_params[:retvals]).to eq(%w(id source category location external_id external_url heading timestamp))
      end
    end

    context 'retvals dont have any allowed value' do
      it 'retvals get default value' do
        env_for_strong_params(stub_hash_from_array([:auth_token, :anchor, :source, :category_group, :category, :country, :state, :metro, :region, :county, :city, :locality, :zipcode, :status, :retvals]))

        filtered_params = controller.instance_eval { poll_params }
        expect(filtered_params[:retvals]).to eq(%w(id source category location external_id external_url heading timestamp))
      end
    end

    context 'retvals are only allowed values' do
      it 'retvals keep existed values' do
        env_for_strong_params({retvals: 'id,account_id,source,category,category_group,location,external_id,external_url,heading,body,html,timestamp,expires,language,price,currency,images,annotations,status,immortal,deleted'})

        filtered_params = controller.instance_eval { poll_params }
        expect(filtered_params[:retvals]).to eq(%w(id account_id source category category_group location external_id external_url heading body html timestamp expires language price currency images annotations status immortal deleted))
      end
    end

    context 'retvals contain forbidden values and allowed values' do
      it 'retvals keep only forbidden values' do
        env_for_strong_params({retvals: 'images,annotations,status,immortal,forbidden_value'})

        filtered_params = controller.instance_eval { poll_params }
        expect(filtered_params[:retvals]).to eq(%w(images annotations status immortal))
      end
    end
  end

  describe '#check format' do
    it 'raise routing error' do
      expect { check_format }.to raise_error
    end
  end
end
