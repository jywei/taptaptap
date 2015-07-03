class EBayPostingProcessor < PostingProcessor
  protected

  def posting_converter(data)
    c = Converter.find_by_source("E_BAY")
    c.convert(data, self)
  end
end