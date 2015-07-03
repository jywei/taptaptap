class RequestStorage
  class << self
    def store_poll_request(request)
      write_data(:poll, request)
    rescue
      # pass
    end

    def store_create_request(request)
      write_data(:create, request)
    rescue
      # pass
    end

    def write_data(request_type, request)
      return unless Rails.env.production?

      File.open(get_log_filename(request_type), 'w') do |f|
        YAML.dump(request.params, f)
      end
    end

    def read_data(request_type, filename)
      return if Rails.env.production?

      YAML.load_file(File.join(get_directory(request_type), "#{filename}.yml"))
    end

    def get_directory(request_type)
      dirname = File.join(Rails.root, %w(log custom requests), request_type.to_s)
      FileUtils.mkdir_p dirname unless Dir.exist? dirname
      dirname
    end

    def get_log_filename(request_type)
      dirname = get_directory(request_type)
      File.join(dirname, "#{DateTime.now.utc.to_i}.yml")
    end

    def restore_request(url, request_type, timestamp)
      data = read_data(request_type, timestamp)

      case request_type.to_sym
        when :create then
          RestClient.post url, data.to_json, content_type: :json, accept: :json

        when :poll then
          RestClient.get "#{url}/poll", data
      end
    end
  end
end
