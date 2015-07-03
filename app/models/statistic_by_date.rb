class StatisticByDate < StatisticBase
  # AR model class
  def self.get_data
    raise 'Abstract method `get_data` called'
  end
end
