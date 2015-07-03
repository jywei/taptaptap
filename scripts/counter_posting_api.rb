require 'parallel'
require 'rest_client'

data = Parallel.map(File.readlines(File.join(File.dirname(__FILE__), 'ips_exhibition2.txt')), :in_threads => 8) do |l| 
  ip = l.strip

  amount = (FirstVolume.first_volume..Posting2.current_volume - 1).map do |volume|
    response = Posting2.connection.query("SELECT COUNT(id) AS cnt FROM postings#{volume} WHERE source = 'CRAIG' AND proxy_ip_address = '#{ip}'").to_a[0]['cnt'].to_i
  end.inject(&:+)

  "#{ ip },#{ amount }\n"
end

File.write "ips_exhibition_counts_postings_api.csv", data.join
