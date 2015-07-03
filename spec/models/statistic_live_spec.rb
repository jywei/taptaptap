require 'spec_helper'
require 'pry-rails'


describe StatisticLive do

  describe "flush_to_db" do
    before(:all) do
      @redis = Redis.new
      keys = @redis.keys "*"
      @redis.del keys if keys.any?

      keys = (0..59).map {|i| "stats:CRAIG:added:#{(Time.now.beginning_of_hour.to_i - 3600 + i.minutes)}"}
      keys.each do |key|
        @redis.set(key, 1)
      end
      @count = 60
      StatisticBySource.destroy_all
      StatisticLive.save_to_db
    end

    it "should create record" do
      expect(StatisticBySource.count).to eq 30
      expect(StatisticBySource.where(source: "CRAIG", deleted: false).size).to eq 1
    end

    it "should save correct counts" do
      statistic = StatisticBySource.find_by(source: "CRAIG", deleted: false)
      expect(statistic.count).to eq @count
    end
  end
end
