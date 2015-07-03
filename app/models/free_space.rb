class FreeSpace
  def self.amount
    str = `df -h`
    str.split("\n")[5].split(' ')[-2].to_i
  end

  def self.record_amount
    SystemEvent.create event: "Space on DB disk used: #{self.amount}%"
  end
end