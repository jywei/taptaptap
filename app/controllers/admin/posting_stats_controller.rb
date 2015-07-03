class Admin::PostingStatsController < ApplicationController
  def index
    @posting_stats = PostingStat.where("updated_at > '#{(Time.now.utc - 30.minutes).to_s(:db)}'").order("id desc")
    render :index
  end
end
