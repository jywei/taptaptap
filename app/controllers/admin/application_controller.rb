class Admin::ApplicationController < ApplicationController
  SCRAPER_INFO_WHITELIST = ['50d6125935648d39a8a0f1a27464c783', '9cda2ae7baec8c7e24f7fba3e3dabf55', '2d4664e2ae76bb20baa36e85f2f02e7e']
  ALLOWED_PAGES = ["admin/scraper_infos"]

  before_filter :authenticate

  private

  def scraper_info_whitelist
    SCRAPER_INFO_WHITELIST + AuthToken.pluck(:token)
  end

  def authenticate
    if (params["auth_token"] ||= session[:auth_token]) && ALLOWED_PAGES.include?(params["controller"])
      unless scraper_info_whitelist.include?(params["auth_token"])
        render text: "Your query does not include a registered auth token. Please sign up for an auth token at https://developer.3taps.com/signup."
        return false
      end
      session[:auth_token] = params["auth_token"]
    else
      authenticate_or_request_with_http_basic do |username, password|
        if username == "3taps" && password == "taptaptap"
          session[:is_admin] = true
        else
          false
        end
      end
    end

    add_breadcrumb :home, :admin_path if session[:is_admin] == true
  end
end
