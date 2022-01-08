ruby '3.1.0'
source 'https://rubygems.org'

gem 'rails', '= 7.0.1'
gem "sprockets-rails", ">= 3.4.1"

# API Helpers
gem 'request_store'

# Rack CORS
gem 'rack-cors', require: 'rack/cors'

# Graphql
gem 'graphql', '= 1.13.0'

# Code services
gem 'dry-monads', require: 'dry/monads/all'

# Global configs
gem 'global', '>= 2.1'

# Database
gem 'mysql2', '~> 0.5'

# Authentication
gem 'bcrypt'
gem 'jwt'

# Background Jobs
gem 'redis'
gem 'sidekiq', '~> 6'
gem 'sinatra', require: false

# Web server
gem 'puma', '>= 5.3.1', '< 6'

group :development, :test do
  # Linting
  gem 'rubocop'

  # Testing
  gem 'rspec'
  gem 'rack-test'

  # Environment bootstrap
  gem 'dotenv-rails'

  # Spring
  gem 'spring'

  # Model Annotations
  # awaiting Rails 7 support - https://github.com/ctran/annotate_models/issues/910#issuecomment-997003275
  git_source(:github) { |repo| "https://github.com/#{repo}.git" }
  gem 'annotate', github: 'dabit/annotate_models', branch: 'rails-7'

  # Seeding information
  gem 'faker'

  # Autoloader filewatching
  gem 'listen', '< 4'
end

group :test do
  # Model factories
  gem 'factory_bot'

  # Database transaction cleaning
  gem 'database_cleaner-active_record'
end
