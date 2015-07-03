class CarsdPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("CARSD")
    c.convert(data, self)
  end

end