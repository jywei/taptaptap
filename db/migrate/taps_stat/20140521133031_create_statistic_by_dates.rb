class CreateStatisticByDates < ActiveRecord::Migration
  def change
    create_table :statistic_by_dates do |t|
      t.string :date, limit: 10

      Posting::TRANSIT_IPS.each do |ip|
        t.string ip.to_sym, limit: 15
      end

      t.date :for_date
      t.timestamps
    end
  end
end
