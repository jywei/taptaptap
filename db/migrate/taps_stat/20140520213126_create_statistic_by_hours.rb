class CreateStatisticByHours < ActiveRecord::Migration
  def change
    create_table :statistic_by_utc_hours do |t|
      t.integer :utc_hour, limit: 2

      Posting::TRANSIT_IPS.each do |ip|
        t.string ip.to_sym, limit: 15
      end

      t.date :for_date
      t.timestamps
    end
  end
end
