require "spec_helper"

describe ProxiesController do

  describe "#proxy" do
    context "with auth_token" do
      it "returns success true" do
        get :proxy, auth_token: 'test_token', url: 'http://en.wikipedia.org/wiki/Rainerius'
        expect(JSON.parse(response.body)["success"]).to eq true
      end

      it "returns json with datas_ize" do
        get :proxy, auth_token: 'test_token', url: 'http://en.wikipedia.org/wiki/Rainerius'
        expect(JSON.parse(response.body)).to include("data_size")
      end
    end

    context "without auth_token" do
      it "returns success false" do
        get :proxy
        expect(JSON.parse(response.body)["success"]).to eq false
      end
    end

    context "auth_token is blank" do
      it "returns success false" do
        get :proxy, auth_token: nil
        expect(JSON.parse(response.body)["success"]).to eq false
      end
    end

    context "with valid url" do
      it "returns success true" do
        get :proxy, auth_token: 'test_token', url: 'http://en.wikipedia.org/wiki/Rainerius'
        expect(JSON.parse(response.body)["success"]).to eq true
      end
    end

    context "with invalid url" do
      it "returns success false" do
        get :proxy, auth_token: 'test_token', url: 'test_url'
        expect(JSON.parse(response.body)["success"]).to eq false
      end
    end

    context "with valid auth_token and url" do
      it "returns json with datas_ize" do
        get :proxy, auth_token: 'my_token', url: 'http://en.wikipedia.org/wiki/Rainerius'
        expect(JSON.parse(response.body)["success"]).to eq true
        expect(JSON.parse(response.body)).to include("data_size")
      end
    end
  end
end