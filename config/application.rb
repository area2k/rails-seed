require File.expand_path('boot', __dir__)

# Manually require Rails engines as needed
require 'rails'

require 'active_model/railtie'
# require 'active_job/railtie'
require 'active_record/railtie'
# require 'active_storage/engine'
# require 'action_controller/railtie'
# require 'action_mailer/railtie'
# require 'action_view/railtie'
# require 'action_cable/engine'
require 'sprockets/railtie'
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../lib/tagged_timestamp_formatter'

def init_logfile(filename)
  dirname = File.dirname(filename)
  return if File.exist?(dirname)

  FileUtils.mkdir_p(dirname)
  FileUtils.touch(filename)
end

# TODO: rename to your application name
module YourApplication
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    # Rails.autoloaders.logger = method(:puts)

    # Disable automatic test code generation
    config.generators do |g|
      g.test_framework = nil
    end

    # Disable belongs_to validation checks required by default
    config.active_record.belongs_to_required_by_default = false

    # Autoload lib/ directory
    config.autoload_paths << "#{config.root}/lib"

    # Log to STDOUT if flag set
    log_output = if ENV['RAILS_LOG_TO_STDOUT']
                   STDOUT
                 else
                   "log/#{Rails.env}.log".tap { |f| init_logfile(f) }
                 end

    # Support tagged logging and timestamp coloring
    logger = ActiveSupport::Logger.new(log_output)
    logger.formatter = TaggedTimestampFormatter

    config.logger = ActiveSupport::TaggedLogging.new(logger)

    # Set default log formatter for env overrides
    config.log_formatter = TaggedTimestampFormatter

    # Add request log tags
    config.log_tags = %i[request_id]
  end
end
