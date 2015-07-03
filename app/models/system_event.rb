class SystemEvent < ActiveRecord::Base
  scope :daily, -> do
    time = Time.now
    where("created_at >= ? and created_at < ?", time - 1.day, time)
  end
end
