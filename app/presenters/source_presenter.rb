class SourcePresenter < BasePresenter
  object :source

  def name
    source['source']
  end

  def timestamp
    @value ||= Time.at(source['timestamp'])
  end
end
