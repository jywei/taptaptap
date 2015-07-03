class SamplePostingsRunner
  STOP_FILE = "log/kill_sample_postings_runner.txt"

  def self.perform
    return if Rails.env.production?

    while true do
      n = 10
      url = (Rails.env == 'staging') ? 'http://staging-posting.3taps.com' : 'localhost:3000'

      SystemData.fill(n, { source: 'CRAIG' }, url)

      if File.exists?(STOP_FILE)
        puts "Removing #{ STOP_FILE } file and stopping the loop"
        %x[rm -f #{ STOP_FILE }]
        break
      end

      sleep 1.minute
    end
  end
end
