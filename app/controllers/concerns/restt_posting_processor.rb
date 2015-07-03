class ResttPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("RESTT")
    c.convert(data, self)
  end
end