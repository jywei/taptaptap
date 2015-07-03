class AutodPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("AUTOD")
    c.convert(data, self)
  end
end