class PostingProfiler
  cattr_accessor :external_id, :posting_id, :timestamps

  @@external_id = nil
  @@posting_id = nil
  @@timestamps = {} # created_at, located_at, anchored_at, polled_at

  class << self
    def flush_vars
      @@external_id = nil
      @@posting_id = nil
      @@timestamps = {}
    end

    def log
      SULO3.error '------------------'
      SULO3.error @@posting_id
      SULO3.error @@timestamps.inspect
    end
  end
end
