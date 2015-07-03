class AptsdPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("APTSD")
    c.convert(data, self)
  end
end