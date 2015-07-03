class HtmlPostingsController < ApplicationController
  def craig
    render json: process_html_posting(DataConverters::Html::Craig)
  end

  private

  def process_html_posting(parser_class)
    data = parser_class.new(params[:html]).parse
    remote_posting = Remote::Posting.new(data) if data
    if remote_posting
      remote_posting.external_url = params[:external_url]
      ids = {
          remote_posting.external_id => remote_posting.save ? remote_posting.id : nil
      }
      remote_posting.client.query %Q(INSERT IGNORE timestamps VALUES (#{remote_posting.timestamp});)

      e = remote_posting.errors.messages.first
      {
          error_responses: [e && e.last.first],
          wait_for: 0,
          ids: ids
      }
    else
      {
          error_responses: [],
          wait_for: 0,
          ids: []
      }
    end
  end
end
