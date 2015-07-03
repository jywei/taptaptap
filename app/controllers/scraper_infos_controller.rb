class ScraperInfosController < ApplicationController
  include ApplicationHelper

  SCRAPER_INFO_WHITELIST = ['50d6125935648d39a8a0f1a27464c783', '9cda2ae7baec8c7e24f7fba3e3dabf55', '2d4664e2ae76bb20baa36e85f2f02e7e']
  SCRAPER_INFO_WHITELIST_IPS = ['108.175.160.26', '108.175.160.34', '108.175.160.18']

  def create
    cors_set_access_control_headers

    response = { success: false, error: "Your query does not include a registered auth token or ip address. Please sign up for an auth token at https://developer.3taps.com/signup." }

    if SCRAPER_INFO_WHITELIST.include?(scraper_params[:auth_token]) || SCRAPER_INFO_WHITELIST_IPS.include?(request.remote_ip)
      res = ScraperInfo.create(
        {
          source: scraper_params[:source],
          event_code: scraper_params[:event_code],
          message: scraper_params[:message]
        }
      )

      if res.errors.empty?
        response = { success: true }
      else
        response = { success: false, errors: res.errors.messages.to_s }
      end
    end

    render json: response
  rescue Exception => e
    SULO8.error "SCRAPERS INFO #POST EXCEPTION:"
    SULO8.error e.message
    SULO8.error e.backtrace
    raise e
  end

  private

  def scraper_params
    params.permit(:auth_token, :source, :event_code, :message)
  end
end