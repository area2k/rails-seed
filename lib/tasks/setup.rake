# frozen_string_literal: true

require 'io/console'

namespace :setup do
  task :env do
    print 'Enter mysql username (default: root):'
    mysql_user = get(default: 'root')

    print 'Enter mysql password (default:):'
    mysql_pass = get(noecho: true)

    print 'Enter redis host (default: localhost:6379)'
    redis_host = get(default: 'localhost:6379')

    print 'Enter redis database (default: 0)'
    redis_db = get(default: '0')

    redis_url = "redis://#{redis_host}/#{redis_db}"

    env = <<~SH
      export MYSQL_USER=#{mysql_user}
      export MYSQL_PASS=#{mysql_pass}

      export REDIS_PROVIDER=REDIS_URL
      export REDIS_URL=#{redis_url}

      export SIDEKIQ_WEB_USER=sidekiq
      export SIDEKIQ_WEB_PASS=sidekiq

      export SECRET_KEY_BASE=#{SecureRandom.hex(64)}
    SH

    test_env = <<~SH
      export MYSQL_USER=#{mysql_user}
      export MYSQL_PASS=#{mysql_pass}

      export REDIS_PROVIDER=REDIS_URL
      export REDIS_URL=#{redis_url}

      export SIDEKIQ_WEB_USER=sidekiq
      export SIDEKIQ_WEB_PASS=sidekiq

      export SECRET_KEY_BASE=#{SecureRandom.hex(64)}
    SH

    File.open(Rails.root.join('.env'), 'w') { |f| f.write(env) }
    File.open(Rails.root.join('.env.test'), 'w') { |f| f.write(test_env) }

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
