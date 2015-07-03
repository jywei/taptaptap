class IndexTrackingWorker
  include Sidekiq::Worker

  def perform(query)
    redis = RedisHelper.hiredis

    index_used = Posting2.connection.query("EXPLAIN #{query}").to_a[0]['key']
    index_used.gsub! /index_(postings\d+_)?on_/i, ''

    redis.write [ 'hincrby', "stats:indexes_usage:indexes", index_used, 1 ]
    redis.read
  end
end