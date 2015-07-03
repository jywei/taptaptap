require 'sidekiq/web'

ThreetapsPostingApi::Application.routes.draw do
  mount Sidekiq::Web, at: "/admin/sidekiq"

  get '/proxy' =>  'proxies#proxy'
  post '/proxy' =>  'proxies#proxy'

  get "/login" => "clients#login"
  post "/login" => "clients#authenticate"
  get '/logout' => "clients#logout"

  get "request_builders/locations" => "request_builders#locations"
  get "request_builders/polling" => "request_builders#polling"
  get "request_builders/reference_api_request" => "request_builders#reference_api_request"

  get "report_data" => "source_category_statistics#index"
  post 'stats' => 'stats#create'

  get '/sources/zip_stats(.:format)' => "zips#old_date_zips"

  get "annotations" => "annotations#index"
  get "available_annotations" => 'annotations_locations#index'
  get 'bckpg_process' => "bckpgs#bckpg_process"
  root 'postings#create', via: :post
  get '/' => 'payment_home#index'
  get 'anchor' => 'postings#anchor'
  get 'anchor2' => 'postings#anchor2'
  get 'poll' => 'postings#poll'
  get 'postings/:id' => 'postings#show'
  get 'pages/health' => 'pages#health'
  scope 'html-postings' do
    post 'craig' => 'html_postings#craig'
  end

  post '/scrapers/info' => 'scraper_infos#create'

  #match 'post_single', to: 'postings#options', via: [:options], constraints: {method: 'OPTIONS'}
  match 'post_single', to: 'postings#create', via: [:post, :options]
  #post 'post_single' => 'postings#create'
  #match 'post_multi', to: 'postings#create', via: [:post, :options]
  post 'post_multi' => 'postings#create'
  post 'post_raw_single' => 'postings#raw_create'
  post 'post_raw_multi' => 'postings#raw_create'

  get "/payment_home" => 'payment_home#index'
  get '/contracts' => 'payment_home#contracts'
  get "/contracts_rates" => 'payment_home#client_rates'
  get "/category_group/:category_group" => 'payment_home#categories', as: :category_group

  resources :demand_source_rates, only: [:index, :edit, :update, :create]

  resources :posting_examples, only: [:new, :create]
  resources :html_examples, only: [:new, :create]
  #get 'admin' => 'admin#index'
  namespace :admin do
    get "posting_stats" => 'posting_stats#index'
    get "insert_profilers" => 'insert_profilers#index'
    get "system_events" => 'system_events#index'
    get "system_events/show" => 'system_events#show'
    get '/' => 'home#index'
    put '/' => 'home#update'

    get '/accounts/refresh' => 'accounts#refresh_approved', as: 'refresh_approved_accounts'

    resources :annotations do
      collection do
        get 'csv' => 'annotations#csv_export', as: 'csv'
      end
    end

    resources :calculate_annotations, only: [ :index ] do
      collection do
        put '/' => 'calculate_annotations#update'
      end
    end

    resources :quality_statistics, only: [ :index ] do
      collection do
        get '/incomplete_annotations' => 'quality_statistics#incomplete_annotations', as: 'incomplete_annotations'
        get '/incomplete_fields' => 'quality_statistics#incomplete_fields', as: 'incomplete_fields'
        match '/with_:attribute' => 'quality_statistics#postings_with_quality', via: [ :get ], constraints: { attribute: /(fields|annotations)_quality/ }, as: 'postings_with_quality'
      end
    end

    get "/annotations_qualities" => 'quality_statistics#annotations_qualities'
    get "/fields_qualities" => 'quality_statistics#fields_qualities'

    resources :converters
    resources :response_counts

    resources :proxy_ips, only: :index

    resources :statistics, only: [ :index ] do
      collection do
        get '/live_data' => 'statistics#live_data', as: 'live_data'
        get '/total_data' => 'statistics#total_data', as: 'total_data'
        get '/us_borders(.:format)' => 'statistics#us_borders'
        get '/states_data(.:format)' => 'statistics#states_data'
        get '/antengo' => 'statistics#antengo', as: 'antengo'
      end

    end

    resources :empty_timestamps, only: [ :index ]
    get "/empty_ids" => "empty_timestamps#show_ids"

    get '/live_lovely' => "live_lovelies#index", as: :live_lovelies

    resources :payment_rates, only: [ :index, :edit, :update ]
    post 'update_categories_rates' => 'payment_rates#update_categories_rates'

    resources :payment_reports, only: :index

    resources :source_accounts, only: :index

    resources :latency_statistics, only: :index

    post "update_latency_offset" => "latency_statistics#update_latency_offset"

    get "latency_hourly" => "latency_statistics#latency_hourly"
    get "latency_daily" => "latency_statistics#latency_daily"
    get "latency_monthly" => "latency_statistics#latency_monthly"
    get "latency_day_hourly" => "latency_statistics#latency_day_hourly"

    get "update_sources" => "backpage_sources#update_sources"
    get "update_file" => "backpage_sources#update_file"
    get "filter_by_address" => "response_counts#filter_by_address"
    get "filter_by_date" => "response_counts#filter_by_date"
    resources :sources, only: :index do
      collection do
        get ":source" => "sources#zips_by_source", as: 'zips_by_source'
        get "/carmakers/:source" => "sources#carmakers_by_source", as: 'carmakers_by_source'
      end
    end

    resources :notifications, only: [:index, :update]
    resources :html_examples, path: 'html-examples', only: [:index, :show] do
      member do
        delete '/' => 'html_examples#reject'
        post '/' => 'html_examples#accept'
        put '/' => 'html_examples#ready'
      end
    end
    scope 'compliances', as: :compliances do
      get '/' => 'compliances#index'
      post '/' => 'compliances#index'
    end

    scope 'parsing', as: :parsing do
      get '/' => 'parsing#index'
      get '/:source' => 'parsing#show', as: :show
      get '/mockup' => 'parsing#show' #trick!?
      post '/' => 'parsing#create'
    end

    resources :exceptions, only: :index do
      # get '/' => 'exceptions#index'
      member do
        get 'retry_last_posting'
        get 'retry_all_postings'
        get 'delete'
        get 'details', as: :details
      end
    end

    resources :auth_tokens

    get '/token_settings/:id' => "auth_tokens#settings", as: :token_settings
    get '/generate_token' => "auth_tokens#generate_token", as: :generate_token

    get '/scrapers/info' => "scraper_infos#index", as: :scraper_infos
    # resources :scraper_infos, only: :index

    scope 'partitions', as: :partitions do
      get '/' => 'partitions#index'
      post '/' => 'partitions#index'
    end
  end
end
