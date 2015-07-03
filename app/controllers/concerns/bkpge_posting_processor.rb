class BkpgePostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("BKPGE")
    c.convert(data, self)
  end
end