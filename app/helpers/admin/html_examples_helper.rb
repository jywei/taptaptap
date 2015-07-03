module Admin::HtmlExamplesHelper
  CLASS_BY_STATUS = {
      'new' => 'warning',
      'rejected' => 'important',
      'accepted' => 'info',
      'ready' => 'success'
  }

  def status_badge(status)
    content_tag 'span', status, class: "badge badge-#{CLASS_BY_STATUS[status]}"
  end
end
