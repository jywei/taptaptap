class Notification::PostingVolume < Notification
  MAX_COUNT = 1_000_000

  def self.notify
    result = false

    @vol1 = volume
    @vol2 = volume - 1

    return false if @vol1 < 0 or @vol2 < 0

    @count1 = db.query("select count(*) from postings#{@vol1}").first.first[1]
    @count2 = db.query("select count(*) from postings#{@vol2}").first.first[1]

    result = if @count1 > MAX_COUNT
               sleep 2
               @fixed1 = fix_error(@vol1)
               true
             end

    result = if @count2 > MAX_COUNT
               sleep 2
               @fixed2 = fix_error(@vol2)
               true
             end

    result
  end

  def self.message
    a = if @fixed1
      ["Table postings#{@vol1} fixed; table had #{@count1} postings"] * 2
    else
      ["Table postings#{@vol1} has #{@count1} postings!"] * 2
    end

    a = if @fixed2
      ["Table postings#{@vol2} fixed; table had #{@count2} postings"] * 2
    else
      ["Table postings#{@vol2} has #{@count2} postings!"] * 2
    end

    if @log
      a.last << "<br/>" << @log
    end

    a
  end

  private

  def self.fix_error(volume)
    dbconn = Posting2.connection

    unless table?('postings_temp')
      dbconn.query("CREATE table postings_temp LIKE postings#{volume}")
    end

    @log = ""
    status_updated = false

    until status_updated
      @log << "===================================<br/>"
      @log << "status updated: #{status_updated}<br/>"

      pending_statuses = dbconn.query("select id, geolocation_status from postings#{volume} where id > #{(volume + 1) * MAX_COUNT}").to_a

      if pending_statuses.blank?
        # @log << "no postings to update<br />"
        next
      end

      pending_statuses = pending_statuses.select { |e| e['geolocation_status'] == 2 }
      count_pending_status = pending_statuses.size
      @log << "count pending status: #{count_pending_status}<br/>"

      if count_pending_status > 0
        @log << "Posting2 current volume: #{Posting2.current_volume}<br/>"

        new_pending_statuses = dbconn.query("select geolocation_status from postings#{volume} where id > #{(volume + 1) * MAX_COUNT}").to_a
        count_new_pending_statuses = new_pending_statuses.blank? ? 0 : new_pending_statuses.count { |e| e['geolocation_status'] == 2 }

        if Posting2.current_volume > volume && count_pending_status == count_new_pending_statuses # double check
          ids = pending_statuses.map { |e| e['id'] }
          dbconn.query("update postings#{volume} set geolocation_status = 1 where id in (#{ids.join(', ')})")
          status_updated = true
          @log << "status updated to true<br/>"
        end
      end
    end

#    count_pending_status = 1
#    while count_pending_status > 0
#      count_pending_status = db.query("select count(*) from postings#{volume}").first.first[1]
#
#      if count_pending_status == 0
#        sleep 1
#        count_pending_status = db.query("select count(*) from postings#{volume}").first.first[1] # double check
#      end
#    end

    dbconn.query("INSERT into postings_temp SELECT * FROM postings#{volume} WHERE id > #{(volume + 1) * MAX_COUNT}")
    dbconn.query("DELETE FROM postings#{volume} WHERE id > #{(volume + 1) * MAX_COUNT}")

    columns = ActiveRecord::Base.connection.columns("postings#{volume}")[1..-1].map { |c| "`#{c.name}`" }
    sql = "INSERT into postings#{volume + 1}(" << columns.join(', ') << ') SELECT ' << columns.join(', ') << ' FROM postings_temp'
    dbconn.query(sql)
    dbconn.query("DROP TABLE postings_temp")

    count = dbconn.query("select count(*) from postings#{volume}").first.first[1]

    if count < MAX_COUNT
      NotificationMailer.notice("1M error in table postings#{volume} fixed").deliver!
    end

    true
  end

  def self.table?(table)
    ActiveRecord::Base.connection.tables.include?(table)
  end
end
