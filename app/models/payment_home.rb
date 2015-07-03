class PaymentHome < PaymentBase
  class << self
    def income(start_date, end_date)
      q = <<-SQL
          SELECT
              SUM(R.rate * S.amount) AS cost
          FROM
              statistic_by_transfered_data AS S
          RIGHT JOIN
              demand_source_rates AS R
          ON
              R.auth_token = S.auth_token AND R.source = S.source AND R.direction = S.direction
          WHERE
              S.for_date >= '#{start_date}' AND S.for_date <= '#{end_date}'
      SQL

      connection.select(q).to_a.first
    end

    def income_by_contracts(start_date, end_date)
      q = <<-SQL
          SELECT
              R.auth_token, SUM(R.rate * S.amount) AS cost
          FROM
              statistic_by_transfered_data AS S
          RIGHT JOIN
              demand_source_rates AS R
          ON
              R.auth_token = S.auth_token AND R.source = S.source AND R.direction = S.direction
          WHERE
              S.for_date >= '#{start_date}' AND S.for_date <= '#{end_date}'
          GROUP BY R.auth_token
          ORDER BY cost DESC
      SQL

      connection.select(q).to_a
    end

    def last_month_incomes
      income_by_contracts((Time.now - 1.month).at_beginning_of_month, (Time.now - 1.month).at_end_of_month)
    end

    def this_month_incomes
      income_by_contracts(Time.now.at_beginning_of_month, Time.now)
    end
  end
end