if %w[development test].include?(Rails.env)
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  frozen_cops = [
    'Style/FrozenStringLiteralComment',
    'Layout/EmptyLineAfterMagicComment',
    'Layout/EmptyLines'
  ]

  RuboCop::RakeTask.new('rubocop:frozen') do |c|
    c.options = ['--auto-correct', "--only=#{frozen_cops.join(',')}"]
  end
end
