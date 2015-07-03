class DefaultPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    DataConverters::Default.new(data, @client).convert
  end
end
