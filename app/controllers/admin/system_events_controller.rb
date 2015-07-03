class Admin::SystemEventsController < ApplicationController
  def index
    @events = SystemEvent.where('created_at > ?', Time.now - 2.days)
  end

  def show
    @event = SystemEvent.find params[:id]
  end
end
