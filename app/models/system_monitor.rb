# new class for rake tasks!
class SystemMonitor
  class << self
    include ActionView::Helpers

    if Rails.env.production?
      CURRENT_IPS = ["108.175.160.26", "127.0.0.1"]
    else
      CURRENT_IPS = RedisHelper.get_redis.smembers('transit_ip_address')
    end
    def save_heartbeats(criteria)
      #DEPRICATE!!!!!
      #SHOULD CRASH REDIS ANY WAY
      difference, step, format =
          case criteria
            when :day then [ 1.day, 1.hour, '%d.%m.%Y:%H:*' ]
            when :hour then [ 1.hour, 1.minute, '%d.%m.%Y:%H:%M:*' ]
            when :minute then [ 1.minute, 1.second, '%d.%m.%Y:%H:%M:%S' ]
            # else [ 1.second, 1.second, '%d.%m.%Y:%H:%M:%S' ]
          end

      time_end = Time.now.utc
      time_start = time_end - difference

      counts = []

      ((time_start.to_i + step) .. time_end.to_i).step(step) do |timestamp|
        time = Time.at(timestamp).utc
        str_key = time.strftime('%d.%m.%Y %H:%M:%S')
        redis_pattern = time.strftime(format)
        redis_keys = RedisHelper.get_redis.keys "total:added:#{ redis_pattern }"
        redis_values = redis_keys.map { |k| RedisHelper.get_redis.get(k).to_i }
        count = redis_values.inject(:+) || 0

        counts << [ str_key, count ]
      end

      counts = counts.uniq { |e| e[0] }

      RedisHelper.get_redis.set "#{ Date.today }:heartbeats:#{ criteria }", YAML.dump(counts)
    end

    def rejected_count
      time = Time.now
      postings = RawPosting.rejected.where("created_at > ?", time - 1.day)

      counted = postings.select('raw_postings.*, COUNT(*) AS group_counter')
      grouped_by_error = counted.group(:error_messages).where("error_messages <> ''").load
      grouped_by_warning = counted.group(:warning_messages).where("warning_messages <> ''").load

      postings.load

      by_errors_message = (grouped_by_error.map { |p| "#{p.error_messages} - #{p.group_counter}" }).join('<br/>')
      by_warnings_message = (grouped_by_warning.map { |p| "#{p.warning_messages} - #{p.group_counter}" }).join('<br/>')

      text = <<-HTML
        <b>total:</b> #{postings.count}<br/>
        <b>rejected sources:</b> #{postings.collect(&:source).uniq}<br/>
        <b>rejected categories:</b> #{postings.collect(&:category).uniq}<br/>
        <b>by errors:</b> #{by_errors_message.blank? ? 0 : by_errors_message}<br />
        <b>by warnings:</b> #{by_warnings_message.blank? ? 0 : by_warnings_message}<br />
      HTML

      SystemEvent.create event: 'rejected count', description: text

      SystemEvent.create event: 'rejected by model validation', description: postings.rejected_by_model.count
      SystemEvent.create event: 'rejected by converter validation', description: postings.rejected_by_converter.count
    end

    def deleted_counts
      time = Time.now.utc
      time_1_day = time - 1.day
      connection = Posting2.connection

      first_volume = Posting2.current_volume
      number_of_volumes = volumes_to_check(connection, first_volume, time)

      the_beginning = FirstVolume.first_volume
      volume = first_volume

      searched_volumes = 0

      # group by hour, category, date
      fields = {
          'HOUR(created_at)' => 'utc_hour',
          'category' => 'category',
          'DATE(FROM_UNIXTIME(timestamp))' => 'date'
      }

      counts = {}

      while (searched_volumes < number_of_volumes) and (volume >= the_beginning)
        fields.each do |field, field_alias|

          q = <<-SQL
            SELECT #{ field } AS 'key', transit_ip_address, COUNT(*) AS 'count'
            FROM postings#{ volume }
            WHERE deleted = 1 AND created_at > '#{ time_1_day }' AND created_at < '#{ time }' AND ( transit_ip_address = '108.175.160.26' OR transit_ip_address = '127.0.0.1')
            GROUP BY #{ field }, transit_ip_address
          SQL

          container_key = field_alias.to_sym
          results = connection.query(q).to_a

          counts[container_key] ||= []
          counts[container_key].concat results
        end

        volume -= 1
        searched_volumes += 1
      end

      counts = Hash[counts.map do |key, counters|
        counters = counters.reject { |e| e['key'].blank? }.group_by { |e| e['key'] }
        counters = Hash[(counters.sort_by { |k, _| k })]
        new_counters = {}
        counters.each do |k1,v1|
          new_counters[k1] = v1.group_by { |e1| e1['transit_ip_address'] }.map{|k,v| Hash[k, v.inject(0){|sum,hash| sum+=hash["count"]} ] }
        end
        [key, new_counters]
      end]

      # count = 0 for ip without deleted postings
      counts.each do |metric, counters|
        counters.each do |key,val|
          present_ips = val.map{ |e| e.keys.first }
          difference = CURRENT_IPS - present_ips
          if difference.present?
            difference.each do |empty_ip|
              counters[key] << { empty_ip => 0 }
            end
          end
        end
      end

      counts[:utc_hour] = (counts[:utc_hour].select { |k, _| k.to_i > 18 }).merge(counts[:utc_hour].select { |k, _| k.to_i < 19 })
      counts[:date] = counts[:date].sort_by{|k, v| k}.reverse

      calculated_count = 0

      counts[:utc_hour].each do |key, value|
        calculated_count += value.inject(0) {|sum, hash| sum + hash.values.sum }
      end

      SystemEvent.create event: "deleted count", description: "deleted postings: #{ calculated_count }"
      NotificationMailer.deleted_notice(counts, calculated_count, time - 3600*24, time).deliver!
    end

    def added_counts(for_day = 1, send_message = true)
      time = Time.now.utc - for_day.days

      added_counts, total_added_counts = get_added_counts(time)

      return unless send_message

      updated_counts = StatisticByUpdates.get_data_for(time.to_date)
      by_source = added_and_updated_counts_by_source(time, for_day)

      SystemEvent.create event: "added count", description: "added postings: #{ total_added_counts }"
      SystemEvent.create event: "updated count", description: "updated postings: #{ updated_counts }"

      NotificationMailer.added_notice(added_counts, total_added_counts, updated_counts, by_source, time).deliver!
    end

    def clean_updated_counts(volume)
      redis = RedisHelper.hiredis
      redis_keys = RedisHelper.scan_for_key "stats:updates:#{volume}:*", redis
      redis_keys.each { |k| redis.write [ 'del', k ] }
      redis_keys.size.times { |_| redis.read }
    end

    def clean_old_latency_statistics
      Posting.table_name = "postings#{ FirstVolume.first_volume }"

      created_at = Posting.order(:created_at).limit(1).pluck(:created_at).first

      StatisticByLatency.clean_old(created_at)
      LatencyHourlyStatistic.clean_old(created_at)
    end

    def empty_sources
      empty_sources = []

      PostingConstants::SOURCES.each do |source|
        key = "added_stats_for:#{ source }"
        value = RedisHelper.get_redis.get(key)

        if value.blank? or value == 0
          empty_sources << source
        end

        RedisHelper.get_redis.set key, 0
      end

      NotificationMailer.empty_sources_notification(empty_sources)
    end

    def system_monitor
      client = Posting2.connection
      r = client.query("show processlist;")
      mysql_clients = r.count

      str = `ps xa | grep runner`
      proc = str.split("\n")
      geo_runners = proc.select { |p| p.match /\/usr(.)*geo_locate_cl/ }.size
      anchor_runners = proc.select { |p| p.match /\/usr(.)*anchor_updater/ }.size
      bkpge_runners = proc.select { |p| p.match /\/usr(.)*BackpageProcess/ }.size

      str = `ps xa | grep unicorn`
      proc = str.split "\n"
      unicorn_workers = proc.select { |p| p.match /unicorn_rails worker(.)*#{Rails.env}/ }.size

      unicorn_stats = ::UnicornStats.new

      SystemState.create(
          geo_runners: geo_runners,
          mysql_processes: mysql_clients,
          unicorn_workers: unicorn_workers,
          anchor_runners: anchor_runners,
          bkpge_runners: bkpge_runners,
          active_unicorn_workers: unicorn_stats.active_workers,
          unicorn_queue: unicorn_stats.queued
      )
    end

    def structure_of_craig_geolocations
      connection = Posting2.connection

      time = Time.now.utc
      geolocation_counts = {}
      categories = %w(total AOTH APET ASUP CCNW CGRP CLNF COMM COTH CRID CVOL DDEL DISP DTAX DTOW JACC JADM JAER JANA JANL JARC JART JAUT JBEA JBIZ JCON JCST JCUS JDES JEDU JENE JENG JENT JEVE JFIN JFNB JGIG JGOV JHEA JHOS JHUM JINS JINT JLAW JLEG JMAN JMAR JMFT JMNT JNON JOPS JOTH JPHA JPRO JPUR JQUA JREA JREC JRES JRNW JSAL JSCI JSEC JSKL JTEL JTRA JVOL JWEB JWNP MESC MFET MJOB MMSG MOTH MPNW MSTR PMSM PMSW POTH PWSM PWSW RCRE RHFR RHFS RLOT ROTH RPNS RSHR RSUB RSWP RVAC RWNT SANC SANT SAPL SAPP SBAR SBIK SBIZ SCOL SEDU SELE SFNB SFUR SGAR SGFT SHNB SHNG SIND SJWL SKID SLIT SMNM SMUS SOTH SRES SSNF STIX STOO STOY STVL SVCC SVCE SVCF SVCH SVCM SVCO SVCP SVCS SWNT VAUT VMOT VMPT VOTH VPAR ZOTH)

      [Posting::GeoStatus::LOCATED_CL_BY_SPREADSHEET, Posting::GeoStatus::LOCATED].each do |geoloc_code|
        categories.each do |category|
          volume = Posting2.current_volume
          count = nil
          calculated_count = 0
          searched_volumes = 0
          number_of_volumes = volumes_to_check(connection, volume, time)

          while (count != 0 or searched_volumes < number_of_volumes) and volume > 0
            count = count_query(connection, volume, geoloc_code, category, time, 'CRAIG')
            calculated_count += count
            volume -= 1
            searched_volumes += 1
          end

          geolocation_counts[category] ||= []
          geolocation_counts[category] << calculated_count
          puts "#{category} : #{calculated_count}"
        end
      end

      NotificationMailer.geolocation_notice(geolocation_counts, time, 'craig geolocation monitor', ['mnakamura@3taps.com', 'marat@3taps.com']).deliver!
    end

    def counts_by_source
      connection = Posting2.connection

      time = Time.now.utc
      first_volume = Posting2.current_volume
      number_of_volumes = volumes_to_check(connection, first_volume, time)

      sources = Posting::SOURCES
      counts = {}
      sources.each do |source|
        volume = first_volume
        count = nil
        calculated_count = 0
        searched_volumes = 0

        while (count != 0 or searched_volumes < number_of_volumes) and volume >= 0
          count = count_query(connection, volume, nil, nil, time, source)
          calculated_count += count
          volume -= 1
          searched_volumes += 1
        end

        counts[source] = calculated_count
        puts "#{source} : #{calculated_count}"
      end

      #NotificationMailer.source_notice(counts, time, 'source counts monitor', ['mnakamura@3taps.com', 'marat@3taps.com', 'b.savchuk@svitla.com']).deliver!
      text = '<br/>'
      counts.each do |source, count|
        text << "#{source}: #{number_with_delimiter count} <br>"
      end

      SystemEvent.create event: "source counts", description: text
    end

    def clear_idle_sources
      RedisHelper.get_redis.del("last_idle_sources")
    end

    def check_redis_free_mem
      redis = RedisHelper.hiredis

      redis.write %w(info memory)

      info = redis.read

      usages = info.split("\r\n").select { |l| l =~ /^used_memory(_peak)?:/ }.map { |l| l.gsub(/^used_memory(_peak)?:([\d\.]+).*/, '\2').to_i }

      return unless (usages[1] - usages[0]) < (usages[1] * 0.25)

      free_mem_human = number_to_human_size(usages[1] - usages[0])

      mail = NotificationMailer.notice_with_attachments("Redis memory is running out. Free mem: #{ free_mem_human }. See excessive keys in the attachment and try to delete deprecated ones.", "warning from 3taps", ["a.shoobovych@svitla.com"], { 'excess_keys.csv' => redis_excess_keys_csv })
      mail.deliver! if Rails.env.production?

      mail
    end

    def redis_excess_keys_csv
      redis = RedisHelper.hiredis

      redis.write ['keys', '*']
      keys = redis.read

      def redis_obj_size(s)
        s.gsub(/^.*serializedlength:(\d+).*$/, '\1').to_i
      rescue
        "n/a"
      end

      # n = keys.size
      # filename = 'log/redis_keys_sizes2.csv'
      batch_size = 1000
      # batches_count = n / batch_size

      # puts "Read all #{n} keys"

      lines = Parallel.map_with_index(keys.each_slice(batch_size)) do |group, gi|
        if Rails.env.production?
          redis = Hiredis::Connection.new
          redis.connect_unix("/tmp/redis.sock")
        else
          redis = RedisHelper.hiredis
        end

        sizes = group.map do |key|
          redis.write [ 'debug', 'object', key ]
          [ key, redis_obj_size(redis.read) ]
        end

        sizes.sort! do |a, b|
          b[1] <=> a[1]
        end

        sizes = sizes.select { |e| e[1] > 1024 * 1024 }.map { |pair| "#{ pair[0] };#{ pair[1] }\n" }

        # print "\rProcessed #{gi} / #{batches_count}"

        sizes.join
      end

      # File.write(filename, lines.join)

      # puts "\nDone"

      lines.join
    end

    private

    def get_added_counts(date)
      time = date
      date = date.strftime("%Y-%m-%d")
      counts =  {}

      hours = (0 .. 23).to_a.map { |h| sprintf('%02d', h) }
      counts[:utc_hour] = added_counts_by(date, hours)

      calculated_count = counts[:utc_hour].values.inject(0) { |s1, e1| s1 += e1.inject(0) { |s2, e2| s2 += e2.values.inject :+ } }

      counts[:category] = added_counts_by(date, Posting::CATEGORIES)

      counts[:date] = added_counts_by_date(date, time, calculated_count)

      save_statistics(counts, date)

      counts_for_report = {}

      counts.each do |key, val|
        counts_for_report[key] = val.each do |k, v|
          Hash[k, v.select! { |hash| CURRENT_IPS.include? hash.keys.first } ]
        end
      end

      counts_for_report.each do |_, val|
        val.select! { |__, v| v.present? }
      end

      totals = counts_for_report[:utc_hour].values.inject(0) { |s1, e1| s1 += e1.inject(0) { |s2, e2| s2 += e2.values.inject :+ } }

      [ counts_for_report, totals ]
    end

    #method gets added counts for utc_hour and category (depending on keys)

    def added_counts_by(date, keys)
      ip_addresses = RedisHelper.get_redis.smembers('transit_ip_address')

      data = {}

      keys.each do |key|
        data[key] = ip_addresses.map do |ip|
          redis_key = "#{date}:#{key}:#{ip}"
          redis_value = RedisHelper.get_redis.get(redis_key)

          { ip => redis_value.to_i } if redis_value.present?
        end

        data[key].compact!
      end

      data.delete_if { |_, v| v.empty? }
    end

    def added_and_updated_counts_by_source(time, for_days)
      data = {}

      added_begin, added_end = time.beginning_of_day.to_i, (time.beginning_of_day + for_days.days).to_i

      redis = RedisHelper.get_redis
      PostingConstants::SOURCES.each do |source|
        redis_added_keys = RedisHelper.scan_for_stats_key("#{source}:added:*", redis)
        filtered_keys =  redis_added_keys.any? ? redis_added_keys.select { |key| key.split(":").last.to_i.between?(added_begin, added_end) } : []
        redis_added_value = filtered_keys.any? ? redis.mget(filtered_keys).reduce(0) {|sum, key|  sum + key.to_i } : 0

        redis_updated_value = StatisticByUpdates.get_data_by_source(time.to_date, source, redis) || 0

        data[source] = { added: redis_added_value.to_i, updated: redis_updated_value }
      end

      data
    end

    #method gets added counts for date
    def added_counts_by_date(date, time, total)
      data = {}
      data_count = 0
      by_time = time
      redis = RedisHelper.get_redis

      while (data_count < total) && (by_time > time - 1.year)
        by_date = by_time.strftime("%Y-%m-%d")

        ip_addresses = redis.smembers('transit_ip_address')

        data[by_date] = ip_addresses.map do |ip|
          redis_key = "#{date}:#{by_date}:#{ip}"
          redis_value = RedisHelper.get_redis.get(redis_key)

          if redis_value.present?
            data_count += redis_value.to_i
            { ip => redis_value.to_i }
          end
        end

        data[by_date].compact!
        by_time -= 1.day
      end

      data.delete_if { |_, v| v.empty? }
    end

    def save_statistics(counts, date)
      return if counts.blank?

      counts.each do |field, value|
        field = field.to_s
        model_class = "StatisticBy#{ field.camelize }".constantize

        value.each do |key, counters|
          counters.each do |ip_count|
            statistics = { field.to_s => key, :for_date => date, :ip_address => ip_count.keys.first }

            if field == 'category'
              category_group = PostingConstants::CATEGORY_RELATIONS_REVERSE[key]
              statistics.merge!({ category_group: category_group })
            end

            record = model_class.find_by(statistics)
            count = ip_count.values.first

            if record
              record.update_attributes({ count: count })
            else
              model_class.create(statistics.merge({ count: count }))
            end
          end
        end
      end
    end

    def count_query(connection, volume, status, category, start_time, source)
      if status && category
        category_criteria, index = category == 'total' ?
            ['', 'index_postings_on_source_and_geolocation_status_and_created_at'] :
            ["and category='#{category}'", 'index_postings_on_source_and_geo_and_category_and_created_at']

        connection.query("select count(*) from postings#{volume} USE INDEX (#{index}) where source='#{source}' and geolocation_status=#{status} #{category_criteria} and created_at > '#{start_time - 1.day}'").to_a.first.values.first
      else
        index = "index_postings#{volume}_on_source_and_created_at"
        connection.query("select count(*) from postings#{volume} USE INDEX (#{index}) where source='#{source}' and created_at > '#{start_time - 1.day}'").to_a.first.values.first
      end
    end

    def volumes_to_check(connection, volume, time)
      count = 1
      vol_time = connection.query("select created_at from postings#{volume} limit 1").to_a.first.values.first

      while vol_time > time - 1.day and volume > 0
        volume -= 1
        count += 1
        vol_time = connection.query("select created_at from postings#{volume} limit 1").to_a.first.values.first
      end

      count
    end
  end
end
