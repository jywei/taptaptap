class HmngsPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("HMNGS")
    c.convert(data, self)
  end
end
