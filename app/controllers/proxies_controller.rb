class ProxiesController < ApplicationController
  include ApplicationHelper
  BYTES_PER_SEND = 1099511628

  def proxy
    check_params

    begin
      if @errors.empty?
        set_params

        get_data_size

        process_metrics

        response = {success: true,  data_size: @data_size, body: @body}
      else
        response = {success: false, errors: @errors}
      end
    rescue => e
      response = {success: false, errors: "please, check params"}
    end

    cors_set_access_control_headers
    render json: response.to_json
  end

  private

  def get_data_size
    proxy = get_proxy

    response = proxy.get_response(@url)
    response_hash = response.to_hash

    if response_hash.include?("x-hola-unblocker-debug")
      matched = response_hash["x-hola-unblocker-debug"].to_s.match /gzip\s*(\d+)\s*/i
      if matched
        @data_size = matched[1]
        @body = response.body
      end
    else
      response = proxy.get(@url)
      @data_size = response.bytesize
      @body = response
    end
  end

  def process_metrics
    redis = RedisHelper.get_redis

    saved_data_size = redis.hget "proxy_api_data_size", @auth_token
    total = saved_data_size.to_i + @data_size.to_i

    if total > BYTES_PER_SEND
      redis.hincrby "usage:#{@auth_token}", "proxy_api_data_size", 1
      redis.hset "proxy_api_data_size", @auth_token, (total - BYTES_PER_SEND)
    else
      redis.hincrby "proxy_api_data_size", @auth_token, @data_size
    end
  end

  def check_params
    @errors = []

    if params.include?(:url)
      @errors << "params 'url' is invalid" unless (params[:url] =~ URI::regexp)
      @errors << "parameter 'url' should not be blank" if params[:url].blank?
    else
      @errors << "parameter 'url' is required and should not be blank"
    end

    @errors << "Your query does not include a registered auth token. Please sign up for an auth token at https://developer.3taps.com/signup." if (!params.include?(:auth_token) || params[:auth_token].blank?)
  end

  def set_params
    @url = params[:url]
    @url = 'http://' + @url unless @url.include?('http://')
    @url = URI(@url)

    @auth_token = params[:auth_token]
    @data_size = nil
    @body = nil
  end

  def get_proxy
    proxy_host = '104.236.130.243'
    proxy_port = 22225
    proxy_user = 'lum-customer-3taps-zone-x'
    proxy_pass = '9c631cb7c3e9'

    Net::HTTP::Proxy(proxy_host, proxy_port, proxy_user, proxy_pass)
  end
end