ruby '2.7.2'
source 'https://rubygems.org'

gem 'rails', '= 6.1.1'

# API Helpers
gem 'request_store'

# Rack CORS
gem 'rack-cors', require: 'rack/cors'

# Graphql
gem 'graphql', '= 1.11.5'
gem 'graphql-batch'
gem 'graphiql-rails'

# Code services
gem 'dry-monads', require: 'dry/monads/all'

# Global configs
gem 'global'

# Database
gem 'mysql2', '~> 0.5'

# Authentication
gem 'bcrypt'
gem 'jwt'

# Background Jobs
gem 'redis'
gem 'sidekiq'
gem 'sinatra', require: false

# Web server
gem 'puma'

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
  gem 'annotate'

  # Seeding information
  gem 'faker'

  # Autoloader filewatching
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  # Model factories
  gem 'factory_bot'

  # Database transaction cleaning
  gem 'database_cleaner'
end
