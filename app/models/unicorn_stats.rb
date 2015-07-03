class UnicornStats
  def initialize
    addr = ["/home/posting/posting/shared/unicorn.sock"]
    @stats = Raindrops::Linux.unix_listener_stats(addr)[addr.first]
  end

  def active_workers
    @stats.active
  end

  def queued
    @stats.queued
  end
end