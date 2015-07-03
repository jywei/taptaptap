class ZipsController < ApplicationController
  include ApplicationHelper

  WHITELIST = ['50d6125935648d39a8a0f1a27464c783', '9cda2ae7baec8c7e24f7fba3e3dabf55']

  def old_date_zips
    response = { success: false, error: "Your query does not include a registered auth token. Please sign up for an auth token at https://developer.3taps.com/signup." }

    if WHITELIST.include?(zips_params[:auth_token])
      cors_set_access_control_headers

      response = ZipsTracker.old_date_zips(zips_params)
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  private

  def zips_params
    params.permit(:source, :auth_token, :hours, :country, :never_received, :amount)
  end
end