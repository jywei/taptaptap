class Admin::ExceptionsController < Admin::ApplicationController
  add_breadcrumb :exceptions_manager, :admin_exceptions_path
  before_action :find_taps_exception, only: [ :retry_all_postings, :retry_last_posting, :delete ]

  def index
    @exceptions = TapsException.all.order('updated_at desc')
  end

  def details
    @exception = TapsException.find(params[:id])

    details = @exception.details || "Nothing to show"
    details = ERB::Util.html_escape details
    message = ERB::Util.html_escape @exception.message

    render json: { title: message, details: details }
  end

  def retry_last_posting
    TapsExceptionsRunner.enqueue_single(@taps_exception.number)

    redirect_to admin_exceptions_path, flash: { info: 'Enqueued' }
  end

  def retry_all_postings
    TapsExceptionsRunner.enqueue_all @taps_exception.number

    redirect_to admin_exceptions_path, flash: { info: 'Enqueued everything' }
  end

  def delete
    TapsException.where(:message => @taps_exception.message).destroy_all

    redirect_to admin_exceptions_path
  end

  protected

  def find_taps_exception
    @taps_exception = TapsException.find(params[:id])
  rescue
    redirect_to admin_exceptions_path, :flash => { :alert => 'Exception could not be found' }
  end
end
