class ScraperInfo < ActiveRecord::Base

  validates :source, presence: true, :inclusion => {:in => Posting::SOURCES, :message => "is not included in list: %{value}"}
  validates :event_code, presence: true, :inclusion => {:in => [1, 2], :message => "is not included in list: %{value}"}
  validates :message, length: { maximum: 256 }

end