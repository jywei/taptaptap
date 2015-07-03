require 'spec_helper'
require 'pry-rails'


describe StatisticByUpdates do

  describe "flush_to_db" do
    before(:all) do
      @redis = Redis.new
      keys = @redis.keys "*"
      @redis.del keys if keys.any?
      StatisticByUpdates.destroy_all

      @redis.set("stats:updates:RENTD:RHFR:#{Date.yesterday}", "1000")
      @redis.set("stats:updates:CRAIG:PPPP:#{Date.yesterday}", "2000")
      @redis.set("stats:updates:CRAIG:RHFS:#{Date.yesterday}", "3000")

      @rentd_count = 1000
      @craig_count = 2000
      @updated_craig_cout = 4000

      StatisticByUpdates.destroy_all
      StatisticByUpdates.create(source: "CRAIG", category: "RHFS", for_date: Time.parse(Date.yesterday.to_s), count: 1000)
      StatisticByUpdates.flush_to_db
    end

    it "should create record" do
      expect(StatisticByUpdates.count).to eq 3
    end

    it "should save correct counts" do
      statistic = StatisticByUpdates.find_by(source: "RENTD")
      expect(statistic.count).to eq @rentd_count
    end

    it "should update count of existing record" do
      statistic = StatisticByUpdates.find_by(source: "CRAIG", category: "RHFS", for_date: Date.yesterday)
      expect(statistic.count).to eq @updated_craig_cout
    end
  end

  describe "get_data_for" do

    context "redis" do
      before :all do
        StatisticByUpdates.destroy_all
        @redis = Redis.new
        keys = @redis.keys "*"
        @redis.del keys if keys.any?
        @redis.set("stats:updates:RENTD:RHFR:#{Date.today}", "1000")
        @data = StatisticByUpdates.get_data_for(Date.today)
      end

      it "should take date from redis" do
        expect(@data).to eq [["RENTD", [["RHFR", 1000]]]]
      end
    end

    context "no data" do
      before(:each) do
        StatisticByUpdates.destroy_all
      end

      let(:data) { StatisticByUpdates.get_data_for(Date.today)}

      it "should return empty array" do
        expect(data).to eq []
      end
    end

    context "from db" do
      before(:each) do
        StatisticByUpdates.destroy_all
      end

      let!(:statistic) { StatisticByUpdates.create(source: "CRAIG", category: "RHFS", for_date: Time.parse(Date.yesterday.to_s), count: 1000) }
      let(:data) { StatisticByUpdates.get_data_for(Date.yesterday) }

      it "should take data from db" do
        expect(data).to eq [["CRAIG", [["RHFS", 1000]]]]
      end
    end
  end
end
