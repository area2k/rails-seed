# frozen_string_literal: true

module ArgumentLoader
  extend ActiveSupport::Concern

  class_methods do
    def argument(keyword, *args, autofetch: nil, **kwargs)
      kwargs[:as] ||= fetched_name(keyword).to_sym if autofetch

      super(keyword, *args, **kwargs).tap do
        create_loader(kwargs[:as], autofetch) if autofetch
      end
    end

    private

    def create_loader(name, loader)
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        # def load_app(value)
        #   __send__(:fetch_app, value)
        # end

        def load_#{name}(value)
          __send__(:#{loader}, value)
        end
      RUBY
    end

    def fetched_name(keyword)
      fetch_name = keyword.to_s

      if fetch_name.ends_with?('_id')
        fetch_name.delete_suffix('_id')
      elsif fetch_name.ends_with?('_ids')
        "#{fetch_name.delete_suffix('_ids')}s"
      else
        fetch_name
      end
    end
  end
end
