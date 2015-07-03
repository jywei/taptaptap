class DrvauPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("DRVAU")
    c.convert(data, self)
  end
end