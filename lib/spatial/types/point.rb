# frozen_string_literal: true

module Spatial
  module Types
    class Point < Geometry
      def type
        :point
      end

      private

      # Structure
      #   4 byte uint   => SRID
      #   1 byte        => Endian-ness flag
      #   4 byte uint   => Geometry type
      #   8 byte double => X value
      #   8 byte double => Y value
      #
      def parse_wkb(value)
        offset = (2 * UINT32_BYTESIZE) + 1
        data = value[offset, 2 * DOUBLE_BYTESIZE]
        lon, lat = data.unpack("#{DOUBLE_PACKFLAG}2")

        Spatial::Point.new(lat, lon)
      end
    end
  end
end
