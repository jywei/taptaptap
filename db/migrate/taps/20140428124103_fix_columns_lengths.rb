class FixColumnsLengths < ActiveRecord::Migration
  def up
    (Posting2.current_volume + 1).upto(LastVolume.last_volume) do |volume|
      table_name = "postings#{ volume }".to_sym

      query = <<-SQL
        ALTER TABLE #{ table_name } MODIFY `source` CHAR(5);
        ALTER TABLE #{ table_name } MODIFY `category` CHAR(4);
        ALTER TABLE #{ table_name } MODIFY `external_id` VARCHAR(20);
        ALTER TABLE #{ table_name } MODIFY `external_url` VARCHAR(385);
        ALTER TABLE #{ table_name } MODIFY `heading` VARCHAR(155);
        ALTER TABLE #{ table_name } MODIFY `language` VARCHAR(2);
        ALTER TABLE #{ table_name } MODIFY `currency` CHAR(3);
        ALTER TABLE #{ table_name } MODIFY `status` VARCHAR(10);
        ALTER TABLE #{ table_name } MODIFY `category_group` CHAR(4);
        ALTER TABLE #{ table_name } MODIFY `country` VARCHAR(3);
        ALTER TABLE #{ table_name } MODIFY `state` VARCHAR(10);
        ALTER TABLE #{ table_name } MODIFY `metro` VARCHAR(7);
        ALTER TABLE #{ table_name } MODIFY `region` VARCHAR(11);
        ALTER TABLE #{ table_name } MODIFY `county` VARCHAR(10);
        ALTER TABLE #{ table_name } MODIFY `city` VARCHAR(12);
        ALTER TABLE #{ table_name } MODIFY `locality` VARCHAR(12);
        ALTER TABLE #{ table_name } MODIFY `zipcode` VARCHAR(9);
        ALTER TABLE #{ table_name } MODIFY `account_id` VARCHAR(10);
        ALTER TABLE #{ table_name } MODIFY `posting_state` VARCHAR(9);
        ALTER TABLE #{ table_name } MODIFY `origin_ip_address` VARCHAR(15);
        ALTER TABLE #{ table_name } MODIFY `transit_ip_address` VARCHAR(15);
        ALTER TABLE #{ table_name } MODIFY `formatted_address` VARCHAR(255);
      SQL

      query.split("\n").each { |line| execute line }
    end
  end
end
