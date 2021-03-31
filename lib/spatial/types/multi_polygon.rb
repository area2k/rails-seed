# frozen_string_literal: true

module Spatial
  module Types
    class MultiPolygon < Geometry
      def type
        :multipolygon
      end

      private

      # Structure
      #   4 byte uint          => SRID
      #   1 byte               => Endian-ness flag
      #   4 byte uint          => Geometry type (6 = 2D MULTIPOLYGON)
      #   4 byte uint          => Number of polygons
      #     1 byte             => Endian-ness flag
      #     4 byte uint        => Geometry type (3 = 2D POLYGON)
      #     4 byte uint        => Number of rings
      #       4 byte uint      => Number of points in ring
      #         8 byte double  => X value
      #         8 byte double  => Y value
      #
      def parse_wkb(value)
        offset = (2 * UINT32_BYTESIZE) + 1
        polygon_count = to_uint32(value[offset, UINT32_BYTESIZE])
        offset += UINT32_BYTESIZE

        polygons = polygon_count.times.map do
          start = offset + UINT32_BYTESIZE + 1
          ring_count = to_uint32(value[start, UINT32_BYTESIZE])
          start += UINT32_BYTESIZE

          rings = ring_count.times.map do
            point_count = to_uint32(value[start, UINT32_BYTESIZE])
            start += UINT32_BYTESIZE

            offset = start + (point_count * DOUBLE_BYTESIZE * 2)
            points = value[start...offset].unpack("#{DOUBLE_PACKFLAG}*")

            start = offset

            points.each_slice(2).map do |lon, lat|
              Spatial::Point.new(lat, lon)
            end
          end

          Spatial::Polygon.new(rings)
        end

        Spatial::MultiPolygon.new(polygons)
      end
    end
  end
end
