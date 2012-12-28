# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  config.preload_frameworks = true

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  %w(observers sweepers mailers modules).each do |dir|
    config.load_paths << "#{Rails.root}/app/models/#{dir}"
  end

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :key => "_foliosus_#{RAILS_ROOT[0,3]}",
    :secret      => '9c9e8d115934dce9cfa7c170972ff72e40337413b70dff8e5846705ab425d0f960ac219e0eb3793cda8f0b59521c52dd782492aaf5f8f39b9dda8e2d6f515ae5'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  config.active_record.observers = :post_sweeper, :client_sweeper, :page_sweeper, :comment_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  config.gem 'hpricot', :version => '0.6.164'
  config.gem 'flickr-fu', :lib => 'flickr_fu', :version => '0.1.4'
  config.gem 'syntax', :lib => 'syntax/convertors/html', :version => '1.0.0'
  config.gem 'mislav-will_paginate', :version => '2.3.7', :lib => 'will_paginate', :source => 'http://gems.github.com'
  
  config.action_mailer.default_url_options = { :host => "foliosus.com" }
end

require 'highlight_fix'

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.update(:url => '%Y/%m/%d')