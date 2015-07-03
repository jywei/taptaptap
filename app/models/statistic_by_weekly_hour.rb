class StatisticByWeeklyHour < StatisticBase
  def self.get_data(start_date, end_date)
    # res = []
    # ((start_date + 1.day)..end_date).each do |date|
    #   res += (0..23).map do |hour|
    #     [
    #         "#{date} #{ hour < 10 ? "0#{hour}" : hour }:00",
    #         rand(42) # where(for_date: date, hour: hour, source: 'CRAIG').pluck('count')
    #     ]
    #   end
    # end

    res = StatisticBySource.where(source: 'CRAIG', for_date: (start_date + 1.day)..end_date, deleted: 0).pluck(:for_date,:utc_hour, :count)
    
    [
        {
            name: "by_weekly_hour",
            data: res.map{|e| ["#{e[0]} #{"%02d" % e[1]}:00", e[2]]}
        }
    ]
  end
end
