class CarauPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("CARAU")
    c.convert(data, self)
  end
end