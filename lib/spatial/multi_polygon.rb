# frozen_string_literal: true

module Spatial
  class MultiPolygon < Geometry
    # WK_PREFIX = [Spatial::WGS84, Spatial::LITTLE_ENDIAN, Spatial::POLYGON_TYPE].freeze

    attr_reader :srid
    attr_accessor :polygons

    class << self
      def from_geojson(coordinates)
        new(coordinates.map do |polygon|
          Polygon.from_geojson(polygon)
        end)
      end
    end

    def initialize(polygons)
      @polygons = polygons
    end

    def ==(other)
      return false unless other.is_a?(MultiPolygon)
      return false unless polygons.size == other.polygons.size

      polygons.each_with_index do |polygon, index|
        return false unless polygon == other.polygons[index]
      end

      true
    end

    def to_a
      polygons.map(&:to_a)
    end

    # TODO: wkb definition
    # def to_wkb
    #   ring_packs = rings.map { |r| "E#{r.points.size * 2}" }

    #   [*WK_PREFIX, *to_a].pack("VCVVV#{ring_packs.join('V')}")
    # end

    def to_wkt
      polygon_text = polygons.map { |p| p.to_wkt.sub('POLYGON', '') }

      "MULTIPOLYGON(#{polygon_text.join(', ')})"
    end
  end
end
