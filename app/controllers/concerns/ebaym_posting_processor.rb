class EbaymPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("EBAYM")
    c.convert(data, self)
  end
end
