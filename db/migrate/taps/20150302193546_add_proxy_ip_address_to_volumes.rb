class AddProxyIpAddressToVolumes < ActiveRecord::Migration
  def change
    Posting2.current_volume.upto(LastVolume.last_volume) do |volume|
      add_column "postings#{volume}", :proxy_ip_address, :string, limit: 15, after: :transit_ip_address, null: true
    end
  end
end
