class Notification::SystemState < Notification
  def self.notify
    @ss = ::SystemState.last
    return false if @ss.blank?
    id = @ss.id
    geo_runners = ::SystemState.select('geo_runners').where("id < #{id}").order("id desc").limit(2).collect(&:geo_runners)
    geo_runners << @ss.geo_runners
    bkpge_runners = ::SystemState.select('bkpge_runners').where("id < #{id}").order("id desc").limit(2).collect(&:bkpge_runners)
    bkpge_runners << @ss.bkpge_runners

    (geo_runners.max < 3) ||
        @ss.mysql_processes > 100 ||
        @ss.unicorn_workers < 6 ||
        @ss.anchor_runners < 1 ||
        #bkpge_runners.max < 1 ||
        @ss.unicorn_queue > 50
  end

  def self.message
    [@ss.inspect, "SystemState in trouble!"]
  end
end
