require 'English'

FOUND_RESULTS = 0
NO_RESULTS = 1
ERROR = 2

DEBUGGING_CODE = [
  '"puts "',
  '" p "',
  '"focus: true"'
].freeze

def green(str)
  "\e[32m#{str}\e[0m"
end

def red(str)
  "\e[31m#{str}\e[0m"
end

if %w[development test].include?(Rails.env)
  namespace :spec do
    desc 'Lint specs for debugging code'
    task :lint do
      puts 'Linting specs...'

      patterns = "-e #{DEBUGGING_CODE.join(' -e ')}"
      command = "grep -nr #{patterns} ./spec/**/*"

      output = `#{command}`
      status = $CHILD_STATUS.exitstatus

      if status == FOUND_RESULTS
        puts red("\nFound #{output.split("\n").size} errors:")
        puts output
        puts "\n"

        abort red('Done, with errors')
      elsif status == ERROR
        puts command
        puts output
        puts "\n"

        abort red('Grep error occurred')
      end

      puts green('Done without errors!')
    end
  end

  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new('spec:integration') do |t|
    t.pattern = 'spec/integration/**{,/*/**}/*_spec.rb'
  end

  RSpec::Core::RakeTask.new('spec:fast') do |t|
    t.exclude_pattern = 'spec/integration/**{,/*/**}/*_spec.rb'
  end

  task 'spec:all' => %w[spec:lint spec:fast spec:integration]

  task(:default).clear
  task default: %w[rubocop spec:all]
  task fast: %w[rubocop spec:fast]
end
