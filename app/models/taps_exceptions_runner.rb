class TapsExceptionsRunner
  class << self
    def enqueue_single(taps_exception_number)
      RedisHelper.get_redis.rpush 'taps_exceptions:resend_one', taps_exception_number
    end

    def enqueue_all(taps_exception_sample_number)
      RedisHelper.get_redis.rpush 'taps_exceptions:resend_all', taps_exception_sample_number
    end

    def resend_single_posting(url = 'localhost:3000')
      queue_name = 'taps_exceptions:resend_one'
      cooldown = 1.minute

      puts "starting..."

      while true
        if RedisHelper.get_redis.llen(queue_name) < 1
          puts "nothing to process"
          sleep cooldown
          next
        end

        taps_exception_number = RedisHelper.get_redis.lpop queue_name

        puts "processing exception ##{taps_exception_number}"

        path = File.join(Rails.root, %w(log custom bodies create))

        exception = TapsException.find_by_number(taps_exception_number)

        filename = File.join path, "#{taps_exception_number}.log"

        unless File.exists?(filename) or exception.present?
          exception.destroy
          puts "does not exist"
          next
        end

        data = File.read filename

        begin
          response = JSON.parse(RestClient.post url, data, :content_type => :json, :accept => :json)
          exception.destroy

          puts "success"
        rescue
          puts "failed"
        end

        puts "=" * 20

        sleep cooldown
      end
    end

    def resend_all_postings(url = 'localhost:3000')
      queue_name = 'taps_exceptions:resend_all'
      cooldown = 1.minute

      puts "starting up the batch processing..."

      while true
        if RedisHelper.get_redis.llen(queue_name) < 1
          puts "nothing to process"

          sleep cooldown
          next
        end

        taps_exception_number = RedisHelper.get_redis.lpop queue_name

        path = File.join(Rails.root, %w(log custom bodies create))

        exception = TapsException.find_by_number(taps_exception_number)

        unless exception.present?
          puts "does not exist anymore"
          next
        end

        msg = exception.message
        exceptions = TapsException.where(message: msg)

        puts "starting to work on a batch of #{ exceptions.size } exceptions sampled from exception ##{ taps_exception_number }"

        res = { success: 0, failed: 0, obsolete: 0 }

        exceptions.each do |e|
          filename = File.join path, "#{e.number}.log"

          unless File.exists? filename
            res[:obsolete] += 1
            e.destroy
            next
          end

          data = File.read filename

          begin
            response = JSON.parse(RestClient.post url, data, :content_type => :json, :accept => :json)
            e.destroy
            res[:success] += 1
          rescue
            res[:failed] += 1
          end
        end

        puts "succeeded: #{ res[:success] }, failed: #{ res[:failed] }, obsolete: #{ res[:obsolete] }"

        puts "=" * 20

        sleep cooldown
      end
    end
  end
end