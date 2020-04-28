# frozen_string_literal: true

module Spatial
  class Polygon < Geometry
    WK_PREFIX = [Spatial::WGS84, Spatial::LITTLE_ENDIAN, Spatial::POLYGON_TYPE].freeze

    Ring = Struct.new(:points)

    attr_reader :srid
    attr_accessor :rings

    def initialize(rings)
      @rings = rings.map { |r| Ring.new(r) }
    end

    def ==(other)
      return false unless other.is_a?(Polygon)
      return false unless rings.size == other.rings.size

      rings.each_with_index do |ring, ring_index|
        other_ring = other.rings[ring_index]

        return false unless ring.points.size == other_ring.points.size

        ring.points.each_with_index do |point, index|
          return false unless point == other_ring.points[index]
        end
      end

      true
    end

    def to_a
      rings.map { |r| r.points.map(&:to_a) }
    end

    def to_wkb
      ring_packs = rings.map { |r| "E#{r.points.size * 2}" }

      [*WK_PREFIX, *to_a].pack("VCVVV#{ring_packs.join('V')}")
    end

    def to_wkt
      ring_text = rings.map do |ring|
        "(#{ring.points.map { |p| "#{p.latitude} #{p.longitude}" }.join(', ')})"
      end

      "POLYGON(#{ring_text.join(', ')})"
    end
  end
end
