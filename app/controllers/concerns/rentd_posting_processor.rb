class RentdPostingProcessor < PostingProcessor
  protected

  def posting_converter(data)
    c = Converter.find_by_source("RENTD")
    c.convert(data, self)
  end
end