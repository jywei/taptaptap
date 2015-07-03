require "spec_helper"

describe PostingsController do
  def create_posting(custom_attributes = {})
    default_attributes = { source: 'JBOOM', timestamp: '123', category: 'APET', status: 'for_sale', external_id: '123', heading: 'heading' }
    data = default_attributes.merge(custom_attributes)
    external_id = data[:external_id]

    post :create, { postings: [ data ] }

    body = JSON.parse(response.body)

    puts "\n>> ERROR CREATING POSTING: #{ body['error_responses'].inspect }" and return nil unless body['error_responses'].compact.empty?

    id = body['ids'][external_id]

    volume = "postings#{ Posting2.volume_by_id(id) }"

    @connection = Mysql2::Client.new(
        {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )

    posting_data = @connection.query("SELECT * FROM #{ volume } WHERE id = #{ id }").first

    OpenStruct.new posting_data
  rescue
    OpenStruct.new data
  ensure
    @connection.close
  end

  def drop_all_postings
    @connection = Mysql2::Client.new(
        {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )

    [nil, 0, 1, 2].each do |v|
      @connection.query "DELETE FROM postings#{v} WHERE 1 = 1"
    end

    @connection.query "UPDATE current_volume SET volume = 0"
    @connection.query "UPDATE last_volume SET volume = 0"
    @connection.query "UPDATE first_volume SET volume = 0"
    @connection.query "DELETE FROM recent_anchors WHERE 1 = 1"
  ensure
    @connection.close
  end

  describe "POST #create" do
    context 'valid posting' do
      before do
        # post :create, {postings: [{source: 'JBOOM', timestamp: '123', category: 'APET', status: 'for_sale', external_id: '123', heading: 'heading'}]}
        create_posting
      end

      it 'create posting' do
        resp = JSON.parse(response.body)
        expect(resp).to include('error_responses' => [nil], 'wait_for' => 0)
        expect(resp).to have_key('ids')
        expect(resp['ids']).to have_key('123')
        expect(resp['ids']['123']).not_to be_nil
      end
    end

    context 'with no posting provided' do
      it 'should fail' do
        post :create, { auth_token: 'token_here' }
        expect(response.body).to eq({success: false, error: 'no posting param in request'}.to_json)
      end
    end

    context 'check fields' do
      before do
        posting_data = {
            source: 'CRAIG',
            category: 'AOTH',
            category_group: 'AAAA',
            account_id: '3',
            location: {
                lat: '32.60986',
                long: '-85.48078',
                country: 'loc2',
                state: 'loc3',
                metro: 'loc1',
                region: 'loc3',
                county: 'loc2',
                city: 'loc3',
                locality: 'loc3',
                zipcode: 'loc3'
            },
            external_id: '122233',
            external_url: 'http://test.url.com/122233',
            heading: 'some heading',
            body: 'some body',
            html: 'some html',
            expires: (Time.now + 1.year).utc.to_i,
            language: 'EN',
            price: 100,
            currency: 'USD',
            images: [{
                         full: 'http://assets.hemmings.com/uimage/10601449-425-0.jpg3'
                     }],
            annotations: {
                Make: 'Rolls Royce',
                Model: 'Phantom I',
                Year: '1928',
                source_subcat: 'bfa'
            },
            status: 'for_sale',
            state: 'expired',
            deleted: false,
            immortal: 'false',
            origin_ip_address: '127.0.0.1',
            transit_ip_address: '111.111.111.111',
            timestamp: Time.now.utc.to_i
        }

        @posting = create_posting(posting_data)
      end

      it 'save easy fields' do
        expect(@posting.created_at).to_not be_nil
        expect(@posting.account_id).to eq('3')
        expect(@posting.category).to eq('AOTH')
        expect(@posting.category_group).to eq('AAAA')
        expect(@posting.currency).to eq('USD')
        expect(@posting.external_id).to eq('122233')
        expect(@posting.external_url).to eq('http://test.url.com/122233')
        expect(@posting.heading).to eq('some heading')
        expect(@posting.html).to eq('some html')
        expect(@posting.language).to eq('EN')
        expect(@posting.price).to eq(100)
        expect(@posting.source).to eq('CRAIG')
        expect(@posting.updated_at).to eq(@posting['created_at'])
      end

      context 'body is nil' do
        before do
          data = {
                      heading: 'heading',
                      source: 'CRAIG',
                      category: 'APET',
                      external_id: 'external_id'
                  }

          @posting = create_posting data

          #@posting = Posting.mysql_connection.query("select * from postings0 where id=#{JSON.parse(response.body)['ids']['external_id']} limit 1").to_a.first
          #@posting = Posting.last
        end

        it 'set empty string' do
          expect(@posting.body).to eq('')
        end
      end

      context 'body is present' do
        before do
          data = {
                      heading: 'heading',
                      source: 'CRAIG',
                      category: 'APET',
                      external_id: 'external_id',
                      body: "sdf ' ff"
                  }

          @posting = create_posting data

          #@posting = Posting.mysql_connection.query("select * from postings0 where id=#{JSON.parse(response.body)['ids']['external_id']} limit 1").to_a.first
        end

        it 'replace \' with \\\' in body' do
          expect(@posting.body).to eq("sdf ' ff")
        end
      end

      context 'annotations is nil' do
        before do
          data = {
                      heading: 'heading',
                      source: 'CRAIG',
                      category: 'APET',
                      external_id: 'external_id'
                  }

          @posting = create_posting data

          #@posting = Posting.mysql_connection.query("select * from postings0 where id=#{JSON.parse(response.body)['ids']['external_id']} limit 1").to_a.first
        end

        it 'saves empty hash' do
          expect(YAML.load @posting.annotations).to eq({})
        end
      end

      context 'annotations are present' do
        before do
          data = {
                      source: 'CRAIG',
                      category: 'APET',
                      heading: 'heading',
                      external_id: 'external_id',
                      annotations: {'ann1' => 'ann1', 'ann2' => 'ann2'}
                  }

          @posting = create_posting data

          # @posting = Posting.mysql_connection.query("select * from postings0 where id=#{JSON.parse(response.body)['ids']['external_id']} limit 1").to_a.first
        end

        it 'save annotations' do
          expect(YAML.load @posting.annotations).to eq({'ann1' => 'ann1', 'ann2' => 'ann2'})
        end
      end

      context 'expires is nil' do
        before do
          data = {
                      source: 'CRAIG',
                      category: 'APET',
                      heading: 'heading',
                      external_id: 'external_id'
                  }

          @posting = create_posting data
        end

        it 'saves 0' do
          expect(@posting.expires).to eq(0)
        end
      end

      context 'expires is present' do
        before do
          data = {
                    source: 'CRAIG',
                    category: 'APET',
                    heading: 'heading',
                    external_id: 'external_id',
                    expires: '4232343'
                }

          @posting = create_posting data
        end

        it 'save expires' do
          expect(@posting.expires).to eq(4232343)
        end
      end

      context 'images is nil' do
        before do
          data = {
                     source: 'CRAIG',
                     category: 'APET',
                     heading: 'heading',
                     external_id: 'external_id'
                 }

          @posting = create_posting data
        end

        it 'saves empty array' do
          expect(YAML.load @posting.images).to eq([])
        end
      end

      context 'images are present' do
        before do
          data = {
                      heading: 'heading',
                      source: 'CRAIG',
                      category: 'APET',
                      external_id: 'external_id',
                      images: {'url' => 'url'}
                  }

          @posting = create_posting data
        end

        it 'save images' do
          expect(YAML.load @posting.images).to eq({'url' => 'url'})
        end
      end

      context 'images are strings' do
        before do
          data = {
                    heading: 'heading',
                    source: 'CRAIG',
                    category: 'APET',
                    external_id: 'external_id',
                    images: ['url']
                 }

          @posting = create_posting data
        end

        it 'save images' do
          expect(YAML.load @posting.images).to eq([{:full => 'url'}])
        end
      end

      context 'status is not hash' do
        before do
          data = {
                  heading: 'heading',
                  source: 'CRAIG',
                  category: 'APET',
                  external_id: 'external_id',
                  status: 'for_sale'
                }

          @posting = create_posting data
        end

        it 'saves status' do
          expect(@posting.status).to eq('for_sale')
        end
      end

      context 'status is hash' do
        before do
          data = {
                      heading: 'heading',
                      source: 'CRAIG',
                      category: 'APET',
                      external_id: 'external_id',
                      status: {'for_sale' => 'true'}
                  }

          @posting = create_posting data
        end

        it 'save status' do
          expect(@posting.status).to eq('for_sale')
        end
      end

      context 'timestamp is not nil or false' do
        before do
          data = {
                      heading: 'heading',
                      source: 'CRAIG',
                      category: 'APET',
                      external_id: 'external_id',
                      timestamp: '434555335'
                  }

          @posting = create_posting data
        end

        it 'saves timestamp' do
          expect(@posting.timestamp).to eq(434555335)
        end
      end

      context 'timestamp is false' do
        before do
          data = {
                      heading: 'heading',
                      source: 'CRAIG',
                      category: 'APET',
                      external_id: 'external_id',
                      timestamp: false
                  }

          @posting = create_posting data
        end

        it 'save timestamp' do
          expect(@posting.timestamp).to_not be_nil
        end
      end
    end

    context 'check posting converter' do
      before do
        @auth_token = '0e6b9ead7eca1caee8dfed7dbdf88447'
        @rejected_post = SystemData.for_converter_test(1, {'source' => 'EBAYM', 'category' => 'SELE'})
        @rejected_posts = SystemData.for_converter_test(5, {'source' => 'EBAYM', 'category' => 'SELE'})
        @accepted_post = SystemData.for_converter_test(1, {'source' => 'EBAYM', 'category' => 'VAUT'})
        @accepted_posts = SystemData.for_converter_test(5, {'source' => 'EBAYM', 'category' => 'VAUT'})
        FactoryGirl.create(:ebaym_converter)
      end

      it 'all postings should save' do
        post :create, { auth_token: @auth_token, postings: @accepted_posts }
        resp = JSON.parse(response.body)
        resp["error_responses"].each { |resp| expect(resp).to be_nil }
      end

      it 'first posting has rejected category, other should save' do
        post :create,  { auth_token: @auth_token, postings: @rejected_post + @accepted_posts }
        resp = JSON.parse(response.body)
        expect(resp["error_responses"].first.first).to include('wrong category_group')
        resp["error_responses"].last(5).each { |resp| expect(resp).to be_nil }
      end

      it 'second posting should not save, other -- save' do
        post :create,  { auth_token: @auth_token, postings: @accepted_post + @rejected_post + @accepted_post }
        resp = JSON.parse(response.body)

        expect(resp["error_responses"].second.first).to include('wrong category_group')
        expect(resp["error_responses"].first).to be_nil
        expect(resp["error_responses"].third).to be_nil
      end

      it 'all postings should not save' do
        post :create,  { auth_token: @auth_token, postings: @rejected_posts }
        resp = JSON.parse(response.body)

        resp["error_responses"].each { |error| expect(error.first).to include('wrong category_group') }
      end
    end
  end

  describe "GET #anchor" do
    context 'no auth_token' do
      it 'returns error' do
        get :anchor, {auth_token: nil, timestamp: 123}
        expect(response.body).to eq({success: false, error: "auth_token is required"}.to_json)
      end
    end

    context 'no timestamp' do
      it 'returns error' do
        get :anchor, {auth_token: '123', timestamp: nil}
        expect(response.body).to eq({success: false, error: "timestamp is required"}.to_json)
      end
    end

    context 'no timestamp and no auth_token' do
      it 'returns error' do
        get :anchor, {format: :json}
        expect(response.body).to eq({success: false, error: "auth_token is required, timestamp is required"}.to_json)
      end
    end

    context 'no records in database' do
      before do
        drop_all_postings
      end

      it 'returns error' do
        get :anchor, {auth_token: 'token', timestamp: 123}
        expect(response.body).to eq({success: false, error: "No anchor found"}.to_json)
      end
    end

    context 'records exist' do
      context 'timestamp is the earliest posting' do
        before do
          drop_all_postings

          timestamps = []
          m_postings = []

          10.times do |n|
            timestamps << timestamp = (n + 1)*10000
            #Posting.mysql_connection.query("insert into postings0 (timestamp) values (#{timestamp})")
            m_postings << create_posting(timestamp: timestamp)
          end

          timestamp_values = timestamps.uniq.map { |t| "(#{t})" }.join(',')
          Posting.mysql_connection.query %Q(INSERT IGNORE timestamps VALUES #{timestamp_values};)

          @last_anchor =  m_postings.first.id
        end

        it 'should return anchor' do
          get :anchor, { auth_token: 'auth_token', timestamp: 10000 }
          expect(response.body).to eq({ success: true, anchor: @last_anchor }.to_json)
        end
      end
    end
  end

  describe "GET #poll" do
    context 'with no auth_token' do
      it 'returns error' do
        get :poll
        expect(response.body).to eq({success: false, error: "auth_token is required"}.to_json)
      end
    end

    context 'with invalid category' do
      it 'returns error' do
        get :poll, {auth_token: '123', category_group: 'asdasd'}
        expect(response.body).to eq({success: false, error: "category_group is invalid (available category_groups are AAAA, CCCC, DISP, SSSS, JJJJ, MMMM, PPPP, RRRR, SVCS, ZZZZ, VVVV)"}.to_json)
      end
    end

    context 'where postings for search are present' do
      context 'and retvals is absent' do
        before do
          m_postings = []
          3.times { m_postings << create_posting(source: 'JBOOM') }
          get :poll, { auth_token: '123', anchor: m_postings[1].id }
          @posting_keys = JSON.parse(response.body)['postings'].first.keys
        end

        it 'returns value for default fields' do
          expect(@posting_keys).to eq(%w(id source category external_id external_url heading timestamp annotations deleted location))
        end
      end

      context 'where search by source' do
        before do
          @m_postings = []

          3.times { @m_postings << create_posting(source: 'JBOOM') }
          2.times { @m_postings << create_posting(source: 'BKPGE') }

          @expected_response = @m_postings.take(3).map { |p| { id: p.id } }
          get :poll, { auth_token: '123', anchor: @m_postings.first.id - 1, source: 'JBOOM', retvals: 'id' }
        end

        it 'returns success' do
          expect(response.body).to eq({ success: true, anchor: @expected_response.last[:id], postings: @expected_response }.to_json)
        end
      end

      context 'where search by category' do
        it 'return success' do
          m_postings = []

          3.times { m_postings << create_posting(category: 'COMM') }
          2.times { m_postings << create_posting(category: 'APET') }

          expected_response = m_postings.take(3).map{ |p| { id: p.id } }

          get :poll, { auth_token: '123', anchor: m_postings.first.id - 1, category: 'COMM', retvals: 'id' }
          expect(response.body).to eq({ success: true, anchor: expected_response.last[:id], postings: expected_response }.to_json)
        end

        it 'returns no postings' do
          m_postings = []

          3.times { m_postings << create_posting(category: 'COMM') }
          3.times { m_postings << create_posting(category: 'APET') }

          get :poll, { auth_token: '123', anchor: m_postings.first.id, category: 'JARC', retvals: 'id' }
          expect(response.body).to eq({ success: true, anchor: m_postings.last.id, postings: [] }.to_json)
        end
      end

      context 'with invalid retvals param' do
        before do
          Posting.table_name = "postings#{ Posting2.current_volume }"
          @query_anchor = Posting.last.id #mysql_connection.query("select id from postings0 order by id asc limit 1").to_a.first['id']
          get :poll, { auth_token: 'auth_token', anchor: @query_anchor.to_i - 1, retvals: 'id,timestamm' }
        end

        it 'should fail' do
          expect(JSON.parse(response.body)['success']).to be_false
        end
      end
    end
  end
end
