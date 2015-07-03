class StatsController < ActionController::Base
  SEARCH_API = ''

  def create
    response = { success: false }

    if params[:auth_token] == SEARCH_API
      category_group = params[:category_group] || params[:category] #Posting::CATEGORY_RELATIONS_REVERSE[params[:category]]

      StatisticByTransferedData.track(
        {
          source: params[:source],
          category_group: category_group,
          amount: params[:count],
          ip: params[:client_ip],
          auth_token: params[:client],
          direction: :search,
          data_size: params[:data_size]
        }
      )

      three_scale_report({
                             user_key: params[:client],
                             usage: {
                                 search_api: 1,
                                 search_api_postings_number: params[:count],
                                 received_data: params[:data_size],
                                 search_api_received_data: params[:data_size]
                             }
                         })

      response = { success: true }
    end

    render json: response
  end

  private
  def three_scale_report(params)
    redis = RedisHelper.hiredis
    redis.write [ 'hincrby', "stats:usage:#{params[:user_key]}", 'search_api', 1 ]
    redis.write [ 'hincrby', "stats:usage:#{params[:user_key]}", 'search_api_postings_number', params[:usage][:search_api_postings_number] ]
    redis.write [ 'hincrby', "stats:usage:#{params[:user_key]}", 'received_data', params[:usage][:received_data] ]
    redis.write [ 'hincrby', "stats:usage:#{params[:user_key]}", 'search_api_received_data', params[:usage][:search_api_received_data] ]
    4.times { redis.read }
  end
end
