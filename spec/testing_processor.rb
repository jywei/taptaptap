class TestingProcessor
  def initialize
    @errors = {}
    @warnings = {}
  end

  def errors
    @errors.values.join(" ")
  end

  def warnings
    @warnings.values.join(" ")
  end

  def add_error(attr, error)
    @errors[attr] ||= []
    @errors[attr] << error
  end

  def add_warning(attr, message)
    @warnings[attr] ||= []
    @warnings[attr] << message
  end
end
