class DomauPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("DOMAU")
    c.convert(data, self)
  end
end