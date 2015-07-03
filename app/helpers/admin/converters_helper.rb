module Admin::ConvertersHelper
  OFF = 'no'
  ON = 'yes'
  
  def write_boolean_attr(var, label = '')
    if label.empty?
      var ? ON : OFF
    else
      "#{label}: <em>#{var ? ON : OFF}</em>"
    end  
  end

  def write_array_attr(var, label = '')
    "#{label}: <em>#{var.join(', ')}</em>"
  end  
end
