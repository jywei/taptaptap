module ApplicationHelper
  def present(object, clazz = nil)
    clazz ||= "#{object.class.name}Presenter".constantize
    decorator = clazz.new(object, self)
    yield(decorator)
    decorator
  end

  def code(inline = nil, &section)
    if block_given?
      content_tag :pre, capture(&section)
    else
      content_tag :code, inline
    end
  end

  def taps_serialize(data, name = nil)
    #if data.is_a? Hash
    #  Hash[data.map { |k, v| [k, v.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '').encode('UTF-8', 'UTF-16')] }].to_yaml
    #elsif data.is_a? Array
    #  data.map { |v| v.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '').encode('UTF-8', 'UTF-16') }.to_yaml
    #else
      #data.to_yaml
    #end

    Oj.dump(data)
  rescue Exception => e
    var_name = name.present? ? "the `#{ name }` variable" : 'data'
    message = "was not able to convert #{ var_name } containing `#{data}` to YAML/JSON. Original exception is #{e.message} (#{ e.backtrace.join }). Trying to fix..."

    SULO1.warn message

    begin
      if data.is_a? Hash
        Oj.dump(Hash[data.map { |k, v| [k, v.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '').encode('UTF-8', 'UTF-16')] }])
      elsif data.is_a? Array
        Oj.dump(data.map { |v| v.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '').encode('UTF-8', 'UTF-16') })
      else
        Oj.dump(data)
      end
    rescue Exception => e2
      var_name = name.present? ? "the `#{ name }` variable" : 'data'
      message = "Could not serialize #{ var_name }, containing `#{ data.inspect }`. Original exception: #{ e2.message }. Trace: #{ e2.backtrace }"

      raise message
    end
  end

  # return the CORS access control headers.
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
  end
end
