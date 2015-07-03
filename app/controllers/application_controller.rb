#class ApplicationController < ActionController::Metal
#  MODULES = [
#      #AbstractController::Layouts,
#      #AbstractController::Translation,
#      #AbstractController::AssetPaths,
#
#      #ActionController::Helpers,
#      #ActionController::HideActions,
#      #ActionController::UrlFor,
#      #ActionController::Redirecting,
#      ActionController::Rendering,
#      ActionController::Renderers::All,
#      #ActionController::ConditionalGet,
#      #ActionController::RackDelegation,
#      #ActionController::Caching,
#      ActionController::MimeResponds,
#      #ActionController::ImplicitRender,
#      #ActionController::StrongParameters,
#
#      #ActionController::Cookies,
#      #ActionController::Flash,
#      #ActionController::RequestForgeryProtection,
#      #ActionController::ForceSSL,
#      #ActionController::Streaming,
#      #ActionController::DataStreaming,
#      #ActionController::HttpAuthentication::Basic::ControllerMethods,
#      #ActionController::HttpAuthentication::Digest::ControllerMethods,
#      #ActionController::HttpAuthentication::Token::ControllerMethods,
#
#      # Before callbacks should also be executed the earliest as possible, so
#      # also include them at the bottom.
#      #AbstractController::Callbacks,
#
#      # Append rescue at the bottom to wrap as much as possible.
#      #ActionController::Rescue,
#
#      # Add instrumentations hooks at the bottom, to ensure they instrument
#      # all the methods properly.
#      ActionController::Instrumentation,
#
#      # Params wrapper should come before instrumentation so they are
#      # properly showed in logs
#      ActionController::ParamsWrapper
#  ]
#
#  MODULES.each do |mod|
#    include mod
#  end
#end


class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  rescue_from Exception, :with => :log_error

  def log_error(exception)
    raise exception unless Rails.env.production?
    now = Time.now
    timestamp = (now.to_f*1000*1000).to_i
    if exception.is_a? Mysql2::Error
      last_time = SystemData.find_by(:name => 'last_mysql_exception_notification_time')
      if last_time.blank? || YAML.load(last_time.value) + 1.hour < Time.now
        message = <<-HTML
          <h1>An exception caught on #{ Rails.env } environment</h1>

          <h2>Message:</h2>
          #{ CGI::escapeHTML exception.message }

          <h2>Stack trace:</h2>
          <ul>
            #{ exception.backtrace.map { |e| "<li>#{ e }</li>" }.join }
          </ul>

          <h2>Log file:</h2>
          <i>#{ timestamp }.log</i>
        HTML

        NotificationMailer.notice(message).deliver! unless Rails.env.development?
        SystemData.find_or_create_by(name: 'last_mysql_exception_notification_time').update_column(:value, Time.now.to_yaml)
      end
    end

    if params[:action] == 'create'
      params.delete(:posting)
      File.open("#{Rails.root}/log/custom/bodies/create/#{timestamp}.log", 'w') {|f| f.write(params.to_json) }
      headers_file = File.join(Rails.root, %w(log custom headers.log))
      File.open(headers_file, 'w') {|f| f.write(request.headers)}
    else
      # File.open("#{Rails.root}/log/custom/bodies/#{timestamp}.log", 'w') {|f| f.write(params) }
    end

    SULOEXC.error '=================== UNHANDLED EXCEPTION ==================='
    SULOEXC.error "Message: #{exception.message}"
    SULOEXC.error "Headers are stored at: #{ headers_file }" if headers_file.present?

    SULOEXC.error '========================== TRACE =========================='
    exception.backtrace.each { |trace| SULOEXC.error trace }
    SULOEXC.error '=========================== $$$ ==========================='

    caused_by = "API (#{ params[:controller] }##{ params[:action] })"
    TapsException.track(message: exception.message, details: params, caused_by: caused_by, number: timestamp)
    # RecentAnchor.first.update_attribute(:anchor_freeze, true)

    @client.close if @client

    render json: {success: false}, status: 202
  end
end
