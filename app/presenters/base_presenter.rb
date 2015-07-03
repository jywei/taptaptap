class BasePresenter
  def self.object(name)
    define_method name do
      @object
    end
  end

  def initialize(object, template)
    @object = object
    @template = template
  end

  def h
    @template
  end

  def method_missing(name)
    @object.try(name)
  end
end
