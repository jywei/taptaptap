class StatisticBySource < StatisticBase
  def self.get_data(date, deleted = false)
    Posting::SOURCES.map do |source|
      {
          name: source,
          data: where(for_date: date, source: source, deleted: deleted).pluck("date, count")
      }
    end
  end
end

