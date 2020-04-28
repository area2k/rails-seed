# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

abort 'The Rails environment is running in production mode!' if Rails.env.production?

require 'spec_helper'

ActiveRecord::Migration.maintain_test_schema!

Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each { |file| require file }

RSpec.configure do |config|
  Rails.application.eager_load!

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.include FactoryGirl::Syntax::Methods

  config.include Rack::Test::Methods, type: :request, file_path: %r{spec/api}
  config.include Support::Requests, file_path: %r{spec/api}

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    if example.metadata[:skip_db_cleaner]
      example.run
    else
      DatabaseCleaner.cleaning { example.run }
    end
  end
end
