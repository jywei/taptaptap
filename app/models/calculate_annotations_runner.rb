class CalculateAnnotationsRunner
  STOP_FILE = "log/kill_calculate_annotations_runner.txt"

  def self.perform
    while true do
      size1 = CalculateAnnotation.count

      CalculateAnnotation.fill

      size2 = CalculateAnnotation.count

      puts "processed #{ size2 - size1 } new annotations"

      if File.exists?(STOP_FILE)
        puts "Removing #{ STOP_FILE } file and stopping the loop"
        %x[rm -f #{ STOP_FILE }]
        break
      end

      sleep 1.minute
    end
  end
end
