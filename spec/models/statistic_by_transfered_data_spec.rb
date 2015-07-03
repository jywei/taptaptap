require 'spec_helper'
require 'pry-rails'


describe StatisticByTransferedData do

  describe "flush_to_db" do
    before(:all) do
      @redis = Redis.new
      keys = @redis.keys "*"
      @redis.del keys if keys.any?
      StatisticByTransferedData.destroy_all

      @redis.set("stats:transfered_data:in:RENTD:RHFR:9cda2ae7baec8c7e24f7fba3e3dabf55:72.55.133.140:#{Date.yesterday}", "1668")
      @redis.set("stats:transfered_data:in:CRAIG:PPPP::108.175.160.26:#{Date.yesterday}", "15180")
      @redis.set("stats:transfered_data:in:BKPGE:RHFS:2d4664e2ae76bb20baa36e85f2f02e7e:174.142.68.176:#{Date.yesterday}", "348")
      @redis.set("stats:transfered_data:in:CRAIG:RHFS::108.175.160.26:#{Date.yesterday}", "59347")

      @redis.set("stats:transfered_bytes:in:RENTD:RHFR:9cda2ae7baec8c7e24f7fba3e3dabf55:72.55.133.140:#{Date.yesterday}", "21882591")
      @redis.set("stats:transfered_bytes:in:CRAIG:PPPP::108.175.160.26:#{Date.yesterday}", "267043703")
      @redis.set("stats:transfered_bytes:in:BKPGE:RHFS:2d4664e2ae76bb20baa36e85f2f02e7e:174.142.68.176:#{Date.yesterday}", "9098868")
      @redis.set("stats:transfered_bytes:in:CRAIG:RHFS::108.175.160.26:#{Date.yesterday}", "1484384092")

      StatisticByTransferedData.flush_to_db
    end

    it "should create record" do
      expect(StatisticByTransferedData.count).to eq 4
    end

    it "should save correct counts" do
      statistic = StatisticByTransferedData.find_by(source: "RENTD", auth_token: "9cda2ae7baec8c7e24f7fba3e3dabf55")
      expect(statistic.amount).to eq 1668
      expect(statistic.data_size).to eq 21882591
    end

  end
end
