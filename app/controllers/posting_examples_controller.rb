class PostingExamplesController < ApplicationController
  def new
    @posting_example = PostingExample.new
  end

  def create
    begin
      @posting = PostingExample.new(posting_example_params)
  	  @posting.save!
    rescue
      details = @posting.present? ? @posting.errors.full_messages : "(not valid JSON in posting field)"
      flash[:error] = "invalid posting example #{details}"
      redirect_to :back and return
    end
    flash[:notice] = "saved"
  	redirect_to new_posting_example_path
  end

  private

  def posting_example_params
  	params[:posting_example][:posting] = JSON.parse(params[:posting_example][:posting]) if params[:posting_example][:posting].present?
  	params.require(:posting_example).permit!
  end
end