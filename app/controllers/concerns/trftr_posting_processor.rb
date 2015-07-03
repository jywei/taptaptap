class TrftrPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("TRFTR")
    c.convert(data, self)
  end
end