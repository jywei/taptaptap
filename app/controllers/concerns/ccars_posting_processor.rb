class CcarsPostingProcessor < PostingProcessor
  protected

  def posting_converter(data)
    c = Converter.find_by_source("CCARS")
    c.convert(data, self)
  end
end