require "spec_helper"

describe PostingsController do
  describe "polling" do
    before do
      PollingPattern.delete_all
    end

    context 'with non-existing polling pattern should persist' do
      it 'and create pattern' do
        expect(NotificationMailer).to receive(:unknown_polling_pattern)
        get 'poll', {"auth_token"=>"99ed3861a2b2ec4c9af5fd1de9fb3892", "anchor"=>"123", "category"=>"RHFR", "retvals"=>"source,timestamp,heading,location,price,annotations,images", "location.state"=>"USA-CA"}
        expect(response).to be_success
      end

      it 'and re-use pattern' do
        expect(NotificationMailer).to_not receive(:unknown_polling_pattern)
        get 'poll', {"auth_token"=>"99ed3861a2b2ec4c9af5fd1de9fb3892", "anchor"=>"123", "category"=>"RHFR", "retvals"=>"source,timestamp,heading,location,price,annotations,images", "location.state"=>"USA-CA"}
        expect(response).to be_success
      end
    end
  end
end
