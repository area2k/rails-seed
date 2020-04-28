module Support
  module SharedContexts
    class << self
      def add_metadata(config, map)
        map.each do |regex, key|
          config.define_derived_metadata(file_path: regex) do |metadata|
            metadata[key] = true
          end
        end
      end
    end
  end
end

RSpec.shared_context 'integration', integration: true do
  around do |example|
    Sidekiq::Testing.inline! { example.run }
  end
end
