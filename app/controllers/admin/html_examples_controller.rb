class Admin::HtmlExamplesController < Admin::ApplicationController
  add_breadcrumb :html_examples, :admin_html_examples_path
  before_action :find_html_example, except: :index
  before_action :add_show_breadcrumb, only: :show

  def index
    @html_examples = HtmlExample.all
  end

  def show
  end

  def accept
    @html_example.accept!
    redirect_to :back
  end

  def reject
    @html_example.reject!
    redirect_to :back
  end

  def ready
    @html_example.ready!
    redirect_to :back
  end

  private

  def find_html_example
    @html_example = HtmlExample.find params[:id]
  end

  def add_show_breadcrumb
    add_breadcrumb @html_example.name, :admin_html_example_path
  end
end
