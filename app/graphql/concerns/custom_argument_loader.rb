# frozen_string_literal: true

module CustomArgumentLoader
  extend ActiveSupport::Concern

  class_methods do
    def argument(*args, autoload: nil, loader: nil, **kwargs)
      resource_name = nil

      if autoload || loader
        name = args[0].to_s
        resource_name = name.delete_suffix(name.ends_with?('_id') ? '_id' : '_ids')
        resource_name = resource_name.to_sym

        kwargs[:as] ||= resource_name
      end

      super(*args, **kwargs).tap do
        loader ||= :default_loader
        create_loader(resource_name, loader: loader) if resource_name
      end
    end

    def create_loader(resource_name, loader:)
      class_eval <<~RUBY
        def load_#{resource_name}(value)
          public_send(:#{loader}, value, argument_name: :#{resource_name})
        end
      RUBY
    end
  end

  def default_loader(value, argument_name:)
    find!(Object.const_get(argument_name.to_s.classify), uuid: value)
  end
end
