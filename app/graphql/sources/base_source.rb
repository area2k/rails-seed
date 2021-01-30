# frozen_string_literal: true

module Sources
  class BaseSource < GraphQL::Dataloader::Source
    protected

    def group_items(items)
      groups = Hash.new { |hash, key| hash[key] = Array.new }
      items.each_with_object(groups) do |elem, acc|
        acc[yield(elem)] << elem
      end
    end

    def map_items(items)
      items.each_with_object({}) do |elem, acc|
        acc[yield(elem)] = elem
      end
    end
  end
end
