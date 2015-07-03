class OodlePostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("OODLE")
    c.convert(data, self)
  end
end