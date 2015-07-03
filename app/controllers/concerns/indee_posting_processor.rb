class IndeePostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("INDEE")
    c.convert(data, self)
  end
end