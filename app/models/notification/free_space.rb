class Notification::FreeSpace < Notification
  def self.notify
    str = `df -h`
    num = str.split("\n")[5].split(' ')[-2].to_i
    num > 80
  end

  def self.message
    ["Free space on disk is less than 20%", "Free space on disk is less than 20%"]
  end
end
