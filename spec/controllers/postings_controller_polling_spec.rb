require "polling_spec_helper"

describe PostingsController do
  context 'with valid retvals params' do

    before(:all) do
      volume = Posting2.current_volume || LastVolume.last_volume
      Posting.table_name = "postings#{ volume }"
      @first_posting = FactoryGirl.create(:posting)
      FactoryGirl.create(:posting)
      @query_anchor = @first_posting.id
    end

    PollingSpecHelper.retvals_combinations.each do |retvals|

      context "containing #{ retvals.inspect } values" do
        before do
          get :poll, { auth_token: PostingsController::SEARCH_API, anchor: @query_anchor, retvals: retvals.join(',') }
          @postings = JSON.parse(response.body)['postings']
        end

        it 'should succeed' do
          retvals.each do |param|
            param_path = param.split('.').map { |e| "[\"#{ e }\"]" }.join
            expect { eval "@posting.first#{ param_path }" }.not_to be_nil
          end
        end
      end

    end
  end
end
