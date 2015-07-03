class SourceCategoryStatisticsController < ApplicationController

  WHITE_LIST = %w(78ca9de153509e584a2f756899c24c4f)

  def index
    if WHITE_LIST.include?(params['token'])
      resonse = {succes: true, data: SourceCategoryStatistic.get_statistic(stat_params) }
    else
      resonse = {succes: false, errors: "Unregister auth_token!!!"}
    end
    render json: resonse
  end

  private

  def stat_params
    params[:for_date] = params[:start_date]..params[:end_date]
    params.slice(:source, :auth_token, :ip, :for_date)
  end
end