# frozen_string_literal: true

task :console do
  require 'irb'
  require 'irb/completion'

  require Rails.root.join('config', 'application.rb')
  Rails.application.require_environment!

  def app
    API::Base
  end

  def json
    JSON.parse(last_response.body, symbolize_names: true)
  end

  include Rack::Test::Methods

  puts "Loading #{Rails.env} environment with app mounted..."

  ARGV.clear
  IRB.start
end
