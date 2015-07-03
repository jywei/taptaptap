class StatisticByVolume < StatisticBase
  def self.get_data(date)
    count = where(created_at: ( date.beginning_of_day .. date.end_of_day )).inject(0) { |acc, stat| acc += stat.count }

    [ date, count ]
  end

  def self.update_stats!
    volumes = LastVolume.last_volume - 1 - FirstVolume.first_volume
    create :count => volumes
  end
end
