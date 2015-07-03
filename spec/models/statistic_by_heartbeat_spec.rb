require 'spec_helper'
require 'pry-rails'

describe StatisticByHeartbeat do

  describe "flush_to_db" do
    before(:all) do
      @redis = Redis.new
      keys = @redis.keys "*"
      @redis.del keys if keys.any?
      StatisticByHeartbeat.destroy_all

      9.times do |i|
        @redis.set("stats:total:added:hour:03.04.2015:0#{i+1}", 10)
      end

      @count = @redis.mget(@redis.keys("stats:total:added:hour:03.04.2015:*")).reduce(0) { |sum, val| sum += val.to_i }
      StatisticByHeartbeat.flush_to_db
    end

    it "should create record" do
      expect(StatisticByHeartbeat.count).to eq 1
    end

    it "should have correct value" do
      statistic = StatisticByHeartbeat.first
      expect(statistic.for_timestamp).to eq Time.parse("03.04.2015")
      expect(statistic.criteria).to eq "hour"
      expect(statistic.count).to eq @count
    end
  end
end
