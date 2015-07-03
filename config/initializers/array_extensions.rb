class Array
  def avg
    self.sum/self.length
  rescue
    0 # for empty arrays
  end
end
