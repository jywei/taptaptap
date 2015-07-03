class IdleSourcesRunner
  STOP_FILE = "log/kill_idle_sources_runner.txt"

  def self.perform
    while true do
      Notification.send_notification Notification::IdleSources

      if File.exists?(STOP_FILE)
        puts "Removing #{ STOP_FILE } file and stopping the loop"
        %x[rm -f #{ STOP_FILE }]
        break
      end

      sleep 1.minute
    end
  end
end
