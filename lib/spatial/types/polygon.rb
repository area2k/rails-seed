# frozen_string_literal: true

module Spatial
  module Types
    class Polygon < Geometry
      def type
        :polygon
      end

      private

      # Structure
      #   4 byte uint   => SRID
      #   1 byte        => Endian-ness flag
      #   4 byte uint   => Geometry type
      #   4 byte uint   => Number of rings
      #     4 byte uint   => Number of points in ring
      #       8 byte double => X value
      #       8 byte double => Y value
      #
      def parse_wkb(value)
        first_ring_offset = (2 * UINT32_BYTESIZE) + 1
        ring_count = to_uint32(value[first_ring_offset, UINT32_BYTESIZE])
        offset = (3 * UINT32_BYTESIZE) + 1

        rings = ring_count.times.map do
          start = offset + UINT32_BYTESIZE
          point_count = to_uint32(value[offset...start])
          offset = (2 * DOUBLE_BYTESIZE * point_count) + start

          points = value[start...offset].unpack("#{DOUBLE_PACKFLAG}*")
          points.each_slice(2).with_object([]) do |(lon, lat), memo|
            memo << Spatial::Point.new(lat, lon)
          end
        end

        Spatial::Polygon.new(rings)
      end
    end
  end
end
