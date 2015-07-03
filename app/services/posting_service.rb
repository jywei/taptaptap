class PostingService
  def inititialize(postings)
    @postings = postings
  end

  def perform


    redis = EM::Protocols::Redis.connect
    redis.errback do |code|
      puts "Error code: #{code}"
    end
    redis.set "a", "foo" do |response|
      redis.get "a" do |response|
        puts response
      end
    end
    # We get pipelining for free
    redis.set("b", "bar")
    redis.get("a") do |response|
      puts response # will be foo
    end
  end
end