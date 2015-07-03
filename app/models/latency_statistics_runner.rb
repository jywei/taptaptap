class LatencyStatisticsRunner
  class << self
    
    def perform

      last_saved_latency = StatisticByLatency.last
      
      if last_saved_latency
        next_id = last_saved_latency.posting_id + latency_offset
      else
        Posting.table_name = "postings#{ FirstVolume.first_volume }"
        next_id = Posting.first.id
      end

      while check_flag?
        volume = Posting2.volume_by_id(next_id)

        Posting.table_name = "postings#{ volume }"
        
        if (next_id + latency_offset) > Posting.last.id
          Posting.table_name = "postings#{ volume + 1 }"
          next_id = Posting.first.id
          volume += 1    
        end

        if volume < Posting2.current_volume     
          LATENCY.info "next id : #{next_id}"

          if posting = Posting.select(:id, :source, :timestamp, :created_at).where(id: next_id).first 
            get_posting_and_save_latency(posting)
            
            next_id += latency_offset                   
          end
        else
          LATENCY.info "pause 1200 seconds"
          sleep 1200
        end    
           
      end
    end

    def get_posting_and_save_latency(posting)
       
      latency = posting.created_at.to_i - posting.timestamp
      
      res = StatisticByLatency.create(
        {
          posting_id: posting.id,
          source: posting.source,
          latency: latency,
          posting_created_at: posting.created_at
        }  
      )
      LATENCY.info "last saved id: #{posting.id}"       
    end

    private

    def check_flag?
      if File.exists?("log/kill_latency_process.txt")
        %x[rm -f log/kill_latency_process.txt]
        false
      else
        true  
      end
    end 

    def latency_offset 
      (RedisHelper.get_redis.get("latency_offset") || 1000).to_i
    end

  end    
end  