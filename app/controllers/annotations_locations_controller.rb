class AnnotationsLocationsController < ApplicationController
  include ApplicationHelper

  WHITE_LIST = ['50d6125935648d39a8a0f1a27464c783']

  before_filter :check_params

  after_filter :cors_set_access_control_headers

  def index
    amount = annotations_params[:amount] || 100

    if @errors.empty?
      response = {success: true, annotations: AnnotationsLocation.select("distinct annotation").where(filtering_params).order(:annotation).limit(amount).pluck(:annotation) }
    else
      @errors = @errors.first if @errors.flatten.first.include?('token')
      response = {status: false, errors: @errors }
    end

    render json: response.to_json
  end

  private

  def filtering_params
    params.slice(:source, :category, :city, :country, :county, :locality, :metro, :region, :state, :zipcode)
  end

  def check_params

    @errors = []

    unless WHITE_LIST.include?(annotations_params[:auth_token])
      @errors << ["Your query does not include a registered auth token or ip address. Please sign up for an auth token at https://developer.3taps.com/signup."]
    end

    if annotations_params[:source].present? &&  !Posting::SOURCES.include?(annotations_params[:source])
      @errors << ["'source' should be one from: #{ Posting::SOURCES.join(", ") }"]
    end

    if annotations_params[:category].present? && !Posting::CATEGORIES.include?(annotations_params[:category])
      @errors << ["'category' should be one from: #{ Posting::CATEGORIES.join(", ") }"]
    end
  end

  def annotations_params
    params.permit(:auth_token, :source, :category, :city, :country, :county, :locality, :metro, :region, :state, :zipcode, :amount)
  end

end