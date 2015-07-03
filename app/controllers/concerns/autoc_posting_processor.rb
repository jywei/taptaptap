class AutocPostingProcessor < PostingProcessor
  protected

  def posting_converter(data)
    c = Converter.find_by_source("AUTOC")
    c.convert(data, self)
  end
end