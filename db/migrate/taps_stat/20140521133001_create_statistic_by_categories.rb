class CreateStatisticByCategories < ActiveRecord::Migration
  def change
    create_table :statistic_by_categories do |t|
      t.string :category, limit: 5

      Posting::TRANSIT_IPS.each do |ip|
        t.string ip.to_sym, limit: 15
      end

      t.date :for_date
      t.timestamps
    end
  end
end
