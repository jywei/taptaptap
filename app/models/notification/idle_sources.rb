class Notification::IdleSources < Notification
  def self.empty_sources
    sources = []

    PostingConstants::SOURCES.each do |source|
      last_source_insert = RedisHelper.get_redis.get("last_source_insert:#{ source }")

      if last_source_insert.blank? or (Time.now.to_i - last_source_insert.to_i) > 10.minutes.to_i
        sources << source
      end
    end

    nothing_changed = sources.all? { |source| RedisHelper.get_redis.sismember("last_idle_sources", source) }

    if nothing_changed
      sources.clear
    else
      RedisHelper.get_redis.del("last_idle_sources")
      RedisHelper.get_redis.sadd("last_idle_sources", sources)
    end

    sources
  end

  def self.notify
    not self.empty_sources.empty?
  end

  def self.message
    empty_sources = self.empty_sources

    if (PostingConstants::SOURCES - empty_sources).empty?
      body = <<-HTML
        <strong>All the sources kept silence for the last 10 minutes</strong>
      HTML
    else
      body = <<-HTML
        <strong>These sources were idle for the last 10 minutes:</strong>

        #{ empty_sources.join(',') }
      HTML
    end

    [ body, 'Idle sources' ]
  end

  def ready?
    (Time.now - self.updated_at) >= 1.minute
  end
end
