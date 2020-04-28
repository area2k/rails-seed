# frozen_string_literal: true

module Spatial
  class Point < Spatial::Geometry
    WK_PREFIX = [Spatial::WGS84, Spatial::LITTLE_ENDIAN, Spatial::POINT_TYPE].freeze

    attr_reader :srid
    attr_accessor :latitude, :longitude

    def initialize(latitude, longitude)
      @latitude = latitude
      @longitude = longitude
    end

    def ==(other)
      return false unless other.is_a?(Point)

      @latitude == other.latitude &&
        @longitude == other.longitude &&
        @srid == other.srid
    end

    def to_a
      [latitude, longitude]
    end

    def to_wkb
      [*WK_PREFIX, *to_a].pack('VCVEE')
    end

    def to_wkt
      "POINT(#{latitude} #{longitude})"
    end
  end
end
