require "spec_helper"

class PollingSpecHelper
  # this number is a parameter to get the combinations.
  # ENLARGE THIS AT YOUR OWN RISK
  # JFYI: for MAX_COMBINATIONS=4 you shall got nearly 20000 combinations
  MAX_COMBINATIONS = 2

  def self.retvals_combinations
    allowed_retvals = %w(id account_id source category category_group location external_id external_url heading body timestamp expires language price currency images annotations status state immortal deleted flagged_status)
    combinations_size = [ allowed_retvals.size, MAX_COMBINATIONS ].min

    (1 .. combinations_size).map { |i| allowed_retvals.combination(i).to_a }.flatten(1)
  end
end
