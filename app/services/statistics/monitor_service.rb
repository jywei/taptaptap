class Statistics::MonitorService
  def self.perform
    Statistic.init unless stat = Statistic.first
    Statistic.perform
  end
end
