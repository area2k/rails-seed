task precommit: :default

namespace :precommit do
  task :install do
    precommit = <<~SH
      #!/bin/sh

      exec time bundle exec rake precommit
    SH

    File.open('./.git/hooks/pre-commit', 'w') { |f| f.write(precommit) }

    puts '- Precommit hook installed'
  end
end
