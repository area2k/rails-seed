# frozen_string_literal: true

require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class Mysql2Adapter < AbstractMysqlAdapter
      NATIVE_DATABASE_TYPES.merge!({
        multipolygon: "MULTIPOLYGON SRID #{Spatial::WGS84}",
        point: "POINT SRID #{Spatial::WGS84}",
        polygon: "POLYGON SRID #{Spatial::WGS84}"
      })

      def quote(value)
        value = value.value_for_database if value.respond_to?(:value_for_database)

        return super unless value.is_a?(Spatial::Geometry)

        "ST_GeomFromText('#{value.to_wkt}', #{Spatial::WGS84})"
      end

      private

      def initialize_type_map(m = type_map)
        super

        m.register_type %r(^point)i, Spatial::Types::Point.new
        m.register_type %r(^polygon)i, Spatial::Types::Polygon.new
        m.register_type %r(^multipolygon)i, Spatial::Types::MultiPolygon.new
      end
    end

    module MySQL
      class SchemaDumper < ConnectionAdapters::SchemaDumper
        def schema_type(column)
          case column.sql_type
          when 'multipolygon', 'point', 'polygon'
            "#{column.sql_type.upcase} SRID #{Spatial::WGS84}"
          else
            super
          end
        end
      end
    end
  end
end

module ArelSpatialFunctions
  def st_distance(geometry, unit: Spatial::UNIT_METER)
    value = Spatial.st_geomfromtext(geometry)
    unit = Arel::Nodes::Quoted.new(unit)

    Arel::Nodes::NamedFunction.new('ST_DISTANCE', [self, value, unit])
  end

  def st_contains(geometry)
    value = Spatial.st_geomfromtext(geometry)

    Arel::Nodes::NamedFunction.new('ST_CONTAINS', [self, value])
  end
end

Arel::Attributes::Attribute.include ArelSpatialFunctions
