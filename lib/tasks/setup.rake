# frozen_string_literal: true

require 'io/console'

namespace :setup do
  task :env do
    print 'Enter mysql username (default: root):'
    mysql_user = get(default: 'root')

    print 'Enter mysql password (default:):'
    mysql_pass = get(noecho: true)

    print 'Enter mysql host (default: localhost:3306):'
    mysql_host = get(default: 'localhost:3306')

    print 'Enter redis host (default: localhost:6379)'
    redis_host = get(default: 'localhost:6379')

    print 'Enter redis database (default: 0)'
    redis_db = get(default: '0')

    env = <<~SH
      export DATABASE_URL=mysql2://#{mysql_user}:#{mysql_pass}@#{mysql_host}

      export REDIS_PROVIDER=REDIS_URL
      export REDIS_URL=redis://#{redis_host}/#{redis_db}
    SH

    File.open(Rails.root.join('.env'), 'w') { |f| f.write(env) }
    Dotenv.load

    puts "\nEnvironment config created"
  rescue StandardError, Interrupt
    puts "\n"
    abort
  end
end

def get(default: '', noecho: false)
  input = noecho ? STDIN.noecho(&:gets) : STDIN.gets
  input = input.chomp

  puts if noecho

  input.present? ? input : default
end

task setup: %w[setup:env db:create precommit:install]
