require 'integration_spec_helper'

describe PostingsController do
  include PostingConstants

  SEARCH_API = ''
  TIMEOUT = 5

  helper = IntegrationSpecHelper.new
  helper.seed_database

  around(:each) do |example|
    Timeout::timeout(TIMEOUT) do
      example.run
    end
  end

  PostingConstants::SOURCES.each do |source|

    context "#{ source } source." do
      context "Integration scenario #1: poll postings by city." do

        helper.cities.product(helper.anchors).each do |city, anchor|

          it "With #{ city } city and #{ anchor } anchor" do
            get :poll, { :auth_token => SEARCH_API, :anchor => anchor, :source => source, 'location.city' => city }
            expect(response).to be_success
          end

        end

      end

      context "Integration scenario #2: poll postings by metro" do

        helper.metro_stations.product(helper.anchors).each do |metro, anchor|

          it "With #{ metro } metro and #{ anchor } anchor" do
            get :poll, { :auth_token => SEARCH_API, :anchor => anchor, :source => source, 'location.metro' => city }
            expect(response).to be_success
          end

        end

      end

      context "Integration scenario #3: poll postings by source" do

        helper.anchors.each do |anchor|

          it "With and #{ anchor } anchor" do
            get :poll, { :auth_token => SEARCH_API, :anchor => anchor, :source => source }
            expect(response).to be_success
          end

        end

      end

      context "Integration scenario #4: poll postings by source and category group" do

        helper.category_groups.product(helper.anchors).each do |category_group, anchor|

          it "With #{ category_group } category group and #{ anchor } anchor" do
            get :poll, { :auth_token => SEARCH_API, :anchor => anchor, :source => source, :category_group => category_group }
            expect(response).to be_success
          end

        end

      end

      context "Integration scenario #5: poll postings by source and category" do

        helper.categories.product(helper.anchors).each do |category, anchor|

          it "With #{ category } category group and #{ anchor } anchor" do
            get :poll, { :auth_token => SEARCH_API, :anchor => anchor, :source => source, :category => category }
            expect(response).to be_success
          end

        end

      end

      context "Integration scenario #6: poll postings by source and status" do

        helper.statuses.product(helper.anchors).each do |status, anchor|

          it "With #{ status } category group and #{ anchor } anchor" do
            get :poll, { :auth_token => SEARCH_API, :anchor => anchor, :source => source, :status => status }
            expect(response).to be_success
          end

        end

      end

      context "Integration scenario #7: create postings" do

        it "Should create postings quickly." do
          post :create, { auth_token: SEARCH_API, postings: [{ source: source, timestamp: '123', category: 'VPAR', status: 'for_sale', external_id: '123', heading: 'heading' }] }
          expect(response).to be_success
        end

      end
    end

  end
end
