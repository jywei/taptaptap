class Admin::SourceAccountsController < Admin::ApplicationController

  def index
    @volume = Posting2.current_volume
    
    @total_count = SourceAccount.get_count_craig(@volume)

    @count_with_source_account = SourceAccount.get_count_craig_with_source_account(@volume)    
    
    add_breadcrumb :source_accounts, :admin_source_accounts_path
  end 

end