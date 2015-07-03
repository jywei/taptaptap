class StatisticByLatency < StatisticBase 

  scope :min_hour, -> { first.posting_created_at.strftime("%Y-%m-%d %H") if first }
  scope :max_hour, -> { last.posting_created_at.strftime("%Y-%m-%d %H") if last }

  scope :min_day, -> { first.posting_created_at.strftime("%Y-%m-%d") if first }
  scope :max_day, -> { last.posting_created_at.strftime("%Y-%m-%d") if last }
  
  scope :min_month, -> { first.posting_created_at.strftime("%Y-%m") if first }
  scope :max_month, -> { last.posting_created_at.strftime("%Y-%m") if last }

  def self.clean_old(created_at)
    connection.execute("DELETE from statistic_by_latencies where posting_created_at < '#{created_at}';")
  end

end
