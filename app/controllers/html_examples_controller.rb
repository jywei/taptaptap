class HtmlExamplesController < ApplicationController
  layout 'base'

  def new
  	@html_example = HtmlExample.new
  end	

  def create
  	begin
      @html_example = HtmlExample.new(html_example_params)
  	  @html_example.save!
    rescue
      details = @html_example.present? ? @html_example.errors.full_messages : "(not valid example data)"
      flash[:error] = "invalid posting example #{details}"
      redirect_to :back and return
    end
    flash[:notice] = "saved"
  	redirect_to new_html_example_path  
  end

  private
  	def html_example_params
    params.require(:html_example).permit!
  end
end
