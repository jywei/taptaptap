class HtmlExamplePresenter < BasePresenter
  object :html_example

  HTML_LIMIT = 5
  URL_LIMIT = 30

  def url_label
    html_example.url.length < URL_LIMIT ? html_example.url : "#{html_example.url[0..URL_LIMIT]}..."
  end

  def short_html
    "#{html_example.html[0..HTML_LIMIT]}..."
  end

  def actions
    h.content_tag :div, class: 'btn-group' do
      "#{reject_link}#{accept_link}#{ready_link}".html_safe
    end
  end

  protected

  def reject_link
    if html_example.new?
      h.link_to 'Reject', h.admin_html_example_path(html_example), class: 'btn btn-danger', method: :delete
    end
  end

  def accept_link
    if html_example.new?
      h.link_to 'Accept', h.admin_html_example_path(html_example), class: 'btn btn-primary', method: :post
    end
  end

  def ready_link
    if html_example.accepted?
      h.link_to 'Ready', h.admin_html_example_path(html_example), class: 'btn btn-success', method: :put
    end
  end
end
