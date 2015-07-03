require 'spec_helper'

describe Admin::SystemEventsController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    let(:system_event) { FactoryGirl.create :system_event }

    it "returns http success" do
      get 'show', id: system_event.id
      response.should be_success
    end
  end

end
