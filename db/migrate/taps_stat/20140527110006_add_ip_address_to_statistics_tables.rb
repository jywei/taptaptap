class AddIpAddressToStatisticsTables < ActiveRecord::Migration
  def change
    add_column :statistic_by_utc_hours, :ip_address, :string, limit: 15
    add_column :statistic_by_utc_hours, :count, :integer
    add_column :statistic_by_categories, :ip_address, :string, limit: 15
    add_column :statistic_by_categories, :count, :integer
    add_column :statistic_by_dates, :ip_address, :string, limit: 15
    add_column :statistic_by_dates, :count, :integer
    
    PostingConstants::TRANSIT_IPS.each do |ip|
      remove_column :statistic_by_utc_hours, ip.to_sym
      remove_column :statistic_by_categories, ip.to_sym
      remove_column :statistic_by_dates, ip.to_sym
    end
  end
end