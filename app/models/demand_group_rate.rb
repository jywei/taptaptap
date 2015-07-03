class DemandGroupRate < PaymentBase
  belongs_to :demand_source_rate

  validates :group, inclusion: { in: Posting::CATEGORY_GROUPS, message: "is not included in list: %{value}"}
end