class RecentAnchor < ActiveRecord::Base
  class << self
    def anchor
      first.try(:anchor) || 1_000_000_000
    end

    def anchor_freeze?
      first.try(:anchor_freeze)
    end

    def precise_anchor
      value = RedisHelper.get_redis.get 'precise_anchor'

      if value.present?
        value.to_i
      else
        SULO8.error "Could not get precise anchor thus using value from database"
        anchor
      end
    end

    def update_precise_anchor(new_value)
      current_value = RedisHelper.get_redis.get 'precise_anchor'

      if current_value.blank? or new_value.to_i > current_value.to_i
        RedisHelper.get_redis.set 'precise_anchor', new_value
      end
    end
  end
end
