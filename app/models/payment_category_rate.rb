class PaymentCategoryRate < PaymentBase

  scope :in, -> { where("direction = 'in'") }
  scope :out, -> { where("direction = 'out'") }
  scope :search, -> { where("direction = 'search'") }

  belongs_to :payment_group_rate
end