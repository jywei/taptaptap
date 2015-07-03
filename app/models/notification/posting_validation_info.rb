class Notification::PostingValidationInfo < Notification

  def self.notify
    @count = PostingValidationInfo.count
    @count != 0
  end


  def self.message
    ["Validation faults: #{@count}", "Validation faults: #{@count}"]
  end
end
