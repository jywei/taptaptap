class PaymentBase < ActiveRecord::Base
  self.abstract_class = true

  establish_connection("taps_payments_#{ Rails.env }".to_sym)
end