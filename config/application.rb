require File.expand_path('../boot', __FILE__)

require 'action_mailer/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require "sprockets/railtie"

#ActiveRecord::Base.logger = Logger.new('/dev/null')

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module ThreetapsPostingApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib)
    config.eager_load_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/rspec)
    config.log_level = :info

    config.filter_parameters += [:postings, :posting] if Rails.env.production?

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '/post_single', :headers => :any, :methods => [:post, :options]
        resource '/post_multi', :headers => :any, :methods => [:post, :options]
      end
    end

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

#     config.middleware.delete "ActionDispatch::Cookies"
#     config.middleware.delete "ActionDispatch::Session::CookieStore"
#     config.middleware.delete "ActionDispatch::Flash"
#     config.middleware.delete "Rails::Rack::Logger"

    # config.active_record.observers = :statistic_observer

    [
        Rack::Sendfile,
        ActionDispatch::Flash,
        ActionDispatch::Session::CookieStore,
        ActionDispatch::Cookies,
        ##ActionDispatch::BestStandardsSupport,
        Rack::MethodOverride,
        ActionDispatch::ShowExceptions,
        ActionDispatch::Static,
        ActionDispatch::RemoteIp,
        #ActionDispatch::ParamsParser,
        Rack::Lock,
    ##ActionDispatch::Head
    ].each do |klass|
      #config.middleware.delete klass
    end
    # config.middleware.delete ActiveRecord::ConnectionAdapters::ConnectionManagement

    #config.middleware.delete "ActionDispatch::Cookies"
    #config.middleware.delete "ActionDispatch::Session::CookieStore"
    #config.middleware.delete "ActionDispatch::Flash"
    #config.middleware.delete "Rails::Rack::Logger"

  end
end
