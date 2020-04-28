# frozen_string_literal: true

require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class Mysql2Adapter < AbstractMysqlAdapter
      def quote(value)
        value = value.value_for_database if value.respond_to?(:value_for_database)

        return super unless value.is_a?(Spatial::Geometry)

        "ST_GeomFromText('#{value.to_wkt}', #{Spatial::WGS84})"
      end

      private

      def initialize_type_map(map = type_map)
        super

        map.register_type(/^point/i, Spatial::Types::Point.new)
        map.register_type(/^polygon/i, Spatial::Types::Polygon.new)
      end
    end
  end
end
