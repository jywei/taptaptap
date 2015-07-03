class Admin::ScraperInfosController < Admin::ApplicationController

  def index
    
    @source = scraper_info_params[:source] || 'all'

    condition = ""

    if session[:is_admin]
      @is_admin = true
      
      @sources = Posting::SOURCES 

      if @sources.include?(@source) || @source == 'all' 
        condition += "source = '#{@source}' "  unless @source == 'all'
      else
        render text: "No such source: #{@source}."
        return false
      end    
    elsif session[:auth_token]
      @sources = AuthToken.find_by(token: session[:auth_token]).sources
      
      if @sources.include?(@source) || @source == 'all'   
        if @source == 'all'
          condition += @sources.map{|source| " source = '#{source}' "}.join(" OR ")
        else
          condition += "source = '#{@source}' "
        end  
      else
        render text: "You haven't rights to view info for this source(or it doesn't exist): #{@source}."
        return false
      end  
    end
    
    @sources.unshift(["All sources", "all"]) if @sources.size > 1  

    @filter = scraper_info_params[:filter]
    
    if @filter.present? 
      if condition.present?
        condition += " AND message like '%#{ @filter }%'"  
      else   
        condition += " message like '%#{ @filter }%'"
      end
    end  
    
    row_per_page = (@source == 'CRAIG') ? 500 : 100

    @events = ScraperInfo.where(condition).order("created_at desc").page(params[:page] || 1).per(row_per_page)
       
    add_breadcrumb "Scraper Info"
  end 


  private

  def scraper_info_params
    params.permit(:source, :filter)
  end  
end  