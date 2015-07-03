class Notification::ColumnsOverflow < Notification
  def self.overflows
    columns = {}

    column_names = RedisHelper.get_redis.hkeys("column_overflow")

    if column_names.present?
      column_names.each do |column|
        columns[column] = RedisHelper.get_redis.hget("column_overflow", column).to_i
      end
    end

    columns
  end

  def self.clear_overflows
    column_names = RedisHelper.get_redis.hkeys("column_overflow")

    if column_names.present?
      column_names.each do |column|
        RedisHelper.get_redis.hset("column_overflow", column, 0)
      end
    end
  end

  def self.notify
    not self.overflows.empty?
  end

  def self.message
    overflows = self.overflows
    allowed = Posting::COLUMNS_WIDTHS

    body = <<-HTML
      <strong>These columns were overflowed:</strong><br />

      #{ (overflows.map { |column, length| "#{ column } - #{ length } out of #{ allowed[column] } <br />" }).join }
    HTML

    [ body, 'Column overflows' ]
  end
end
