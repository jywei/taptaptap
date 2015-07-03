class PostingThreshold < ActiveRecord::Base
  def current_minute
    timestamp = Time.now

    id1,id2 = select('posting_id').
        where("posting_created_at >= ?", timestamp).
        order('id asc').
        limit(2).
        collect(&:posting_id)
  end

  def current_hour
    timestamp = Time.now.beginning_of_hour

    id1 = select('posting_id').where("posting_created_at >= ?", timestamp).
        limit(1).first.posting_id

    id2 = select('posting_id').where("posting_created_at >= ?", timestamp + 3600).
        limit(1).first.posting_id

    [id1, id2]
  end

  def current_day
    timestamp = Time.now.beginning_of_day

    id1 = select('posting_id').where("posting_created_at >= ?", timestamp).
        limit(1).first.posting_id

    id2 = select('posting_id').where("posting_created_at >= ?", timestamp + 1.day).
        limit(1).first.posting_id

    [id1, id2]
  end

  class << self
    def dropped_volume(volume)
      connection = Posting2.connection

      postings = connection.query("SELECT MIN(id) AS first_posting, MAX(id) AS last_posting FROM postings#{volume}").to_a.first
      first_posting, last_posting = postings['first_posting'], postings['last_posting']

      p "No postings in volume #{volume}" and return  if first_posting.nil? or last_posting.nil?

      connection.query("DELETE FROM posting_thresholds WHERE posting_id IN (#{ first_posting }, #{ last_posting })")
    end

    def runner
      stop_file = "#{Rails.root}/log/stop_threshold_runner.txt"

      while true do
        if File.exists?(stop_file)
          File.delete(stop_file)
          break
        end

        time = Time.now
        sleep (60 - time.sec - 5) # wait until new minute starts

        volume = Posting2.current_volume
        Posting.table_name = "postings#{volume}"
        posting = Posting.select('id,created_at').order('id desc').limit(1).first
        min = posting.created_at.min

        while posting.created_at.min == min
          posting = Posting.select('id,created_at').order('id desc').limit(1).first
        end

        create(posting_id: posting.id, posting_created_at: posting.created_at)
      end
    rescue Exception => e
      TapsException.track(message: e.message, notify: true, details: e.backtrace.join(', '), module_name: 'posting threshold runner')
    end

    def runner_missed_volumes
      logger = Logger.new("#{Rails.root}/log/custom/threshold_missed_volumes.log")

      last_threshold = last

      unless last_threshold
        Posting.table_name = "postings#{FirstVolume.first_volume}"
        posting = Posting.first
        last_threshold = create(posting_id: posting.id, posting_created_at: posting.created_at)
      end

      volume_start =  Posting2.volume_by_id last_threshold.posting_id
      volume_end = Posting2.current_volume

      logger.info "from volume: #{volume_start}"
      logger.info "to volume: #{volume_end}"

      volume_start.upto(volume_end) do |volume|
        query = "SELECT DISTINCT(`created_at`) AS `posting_created_at`, `id` AS `posting_id` FROM postings#{ volume } WHERE SECOND(created_at) = 0 AND `created_at` > '#{last_threshold.posting_created_at}'  GROUP BY `created_at`;"
        data = Posting2.connection.query(query).to_a
        data.each{|hash| hash["posting_created_at"] = hash["posting_created_at"].to_s(:db)}
        res = create data
        logger.info "volume: #{volume}, created: #{res.count}"
      end
    end

    def get_id_by_timestamp(timestamp)
      time = Time.at(timestamp).utc

      @client = Posting2.connection

      posting_id = @client.query("SELECT posting_id FROM `posting_thresholds` WHERE  `posting_created_at` = '#{time.to_s(:db)}' LIMIT 1").to_a[0].try(:[], 'posting_id')

      return posting_id if posting_id

      time_start = time.at_beginning_of_minute

      first_threshold = first
      last_threshold = last

      if time_start < first_threshold.posting_created_at
        Posting.table_name = "postings#{Posting2.volume_by_id(first_threshold.posting_id)}"
        Posting.first.id
      elsif time_start > last_threshold.posting_created_at
        Posting.table_name = "postings#{Posting2.volume_by_id(last_threshold.posting_id)}"
        Posting.last.id
      else
        first_id = @client.query("SELECT posting_id FROM `posting_thresholds` WHERE  `posting_created_at` >= '#{time_start.to_s(:db)}' LIMIT 1").to_a[0].try(:[], 'posting_id')
        last_id = @client.query("SELECT posting_id FROM `posting_thresholds` WHERE  `posting_id` > #{first_id} LIMIT 1").to_a[0].try(:[], 'posting_id')

        last_id = first_id unless last_id

        first_volume = Posting2.volume_by_id first_id
        last_volume = Posting2.volume_by_id last_id

        id = @client.query("SELECT id FROM `postings#{first_volume}` WHERE  `created_at` >= '#{time.to_s(:db)}' ORDER BY ABS(`created_at` - '#{time}') LIMIT 1").to_a[0].try(:[], 'id')
        unless id
          id = @client.query("SELECT id FROM `postings#{last_volume}` WHERE  `created_at` >= '#{time.to_s(:db)}' ORDER BY ABS(`created_at` - '#{time}') LIMIT 1").to_a[0].try(:[], 'id')
        end

        id
      end
    end

    def catchup
      pt = last
      volume = pt.posting_id / 1_000_000 + 1
      Posting.table_name = "postings#{volume}"
      current_volume = Posting2.current_volume

      while volume <= current_volume
        while posting = Posting.select('id, created_at').where("created_at >= '#{(pt.posting_created_at + 1.minute).beginning_of_minute}'").limit(1).first
          pt = PostingThreshold.create(posting_id: posting.id, posting_created_at: posting.created_at)
        end
      end

    end
  end

end
