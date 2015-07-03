class ResponseCount < ActiveRecord::Base

  def self.count_per_day(address)
    count_per_day = []
    (0..10).each do |i|
      response = all.where(created_at: (Time.now - i.day).midnight..(Time.now - i.day).end_of_day, request_ip: address).to_a
      unless response.blank?
        sum = response.sum(&:count)
        average = sum / response.count
        count_per_day << [sum, average, response[0][:created_at].to_date.to_s]
      end
    end
    count_per_day
  end

  def self.count_for_address(date)
    counts = []
    ips_in_day = all.where(created_at: date.to_time.midnight..date.to_time.end_of_day).to_a
    ips = ips_in_day.uniq{|x| x[:request_ip]}
    sum = j = 0
    ips.each do |ip|
      ips_in_day.each do |i|
        if i[:request_ip] == ip[:request_ip]
          sum = sum + i[:count]
          j = j + 1
        end
      end
      average = sum / j
      counts << [ip[:request_ip], sum, sum/j]
      sum = j = 0
    end
    counts
  end
end