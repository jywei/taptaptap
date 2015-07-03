class CraigPostingProcessor < PostingProcessor

  protected

  def posting_converter(data)
    c = Converter.find_by_source("CRAIG")
    c.convert(data, self)
  end
end