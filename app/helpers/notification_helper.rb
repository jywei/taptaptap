module NotificationHelper
  def count_for_ip(data)
    data.inject(0) { |sum, hash| sum + hash.values.sum } 
  end

  def get_ips(data)
    res = []
    if data.present?
      data.each do |key, value|
        value.each{|hash| res << hash.keys.first}
      end
    end
    res.uniq.sort if res.present?
  end

  def total_by_ip(data) 
    if data.present?
      res = {}
      get_ips(data).each do |ip| 
        sum = 0
        data.each do |k,v| 
          v.each do |hash| 
            if hash.keys.first == ip 
              sum += hash[ip]
            end  
          end      
        end
        res[ip] = sum
      end
      res
    end
  end

  def max_ip(data)
    if data.present?
      data.max_by{|k,v| v}.first
    end  
  end  

  def sort_category_by_max_ip(data)
    m_ip = max_ip(total_by_ip(data))
    #add 0 to array, wich hasn't max_ip
    data = Hash[data.each do |k,val| 
      if val.select{|v| v.keys.first == m_ip}.empty? 
        val << Hash[m_ip,0] 
      end
    end]
    #sort by max_ip count
    data = Hash[data.sort_by{|k,v| v.select{|v| v.keys.first == m_ip}.first.values.first}.reverse]
    data.each do|k,val| 
      val.select!{|v| v.values.first >= 0}
    end 
  end  
end  