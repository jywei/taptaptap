class Admin::PaymentHomeController < ApplicationController
  layout 'admin/payments'

  def index
    contracts = DemandSourceRate.last_month.group(:auth_token).all.count
    income = StatisticByTransferedData.last_month.pluck(:amount).sum

    @last_month = {
        contracts: contracts,
        income: income
    }

    contracts = DemandSourceRate.this_month.group(:auth_token).all.count
    income = StatisticByTransferedData.this_month.pluck(:amount).sum

    @this_month = {
        contracts: contracts,
        income: income
    }
  end
end
