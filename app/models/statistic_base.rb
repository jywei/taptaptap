class StatisticBase < ActiveRecord::Base
  self.abstract_class = true

  establish_connection("taps_stat_#{ Rails.env }")
end
