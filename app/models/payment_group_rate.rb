class PaymentGroupRate < PaymentBase
  scope :in, -> { where("direction = 'in'") }
  scope :out, -> { where("direction = 'out'") }
  scope :search, -> { where("direction = 'search'") }

  belongs_to :payment_rate

  has_many :payment_category_rates, dependent: :destroy
  accepts_nested_attributes_for :payment_category_rates
end