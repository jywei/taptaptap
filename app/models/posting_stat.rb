class PostingStat < ActiveRecord::Base
  belongs_to :posting

  scope :not_polled, -> { where("polled_at IS NULL") }
  scope :not_anchored, -> { where("anchored_at IS NULL") }
end
