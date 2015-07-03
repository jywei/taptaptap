class Admin::ProxyIpsController < Admin::ApplicationController

  def index
    Posting.table_name = "postings#{ Posting2.current_volume }"
    @postings = Posting.select(:id, :proxy_ip_address)
                .where("proxy_ip_address is not null AND  proxy_ip_address != ''")
                .page(params[:page] || 1).per(100)

    add_breadcrumb "Proxy ip address"
  end
end