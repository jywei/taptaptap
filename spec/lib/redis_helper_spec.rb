require 'spec_helper'
require 'redis_helper'
require 'pry-rails'

describe RedisHelper do
  before(:each) do
    @redis = Redis.new
    keys = @redis.keys "*"
    @redis.del keys if keys.any?
    10.times do |i|
      @redis.set("stats:#{i+1}", '1')
    end
  end

  describe "scan for stats keys" do
    it "should find 10 keys" do
      keys = RedisHelper.scan_for_stats_key('*')
      expect(keys.length).to eq 10
      expect(keys).to include "1"
    end
  end
end
