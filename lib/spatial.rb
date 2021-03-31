# frozen_string_literal: true

module Spatial
  BIG_ENDIAN = 0
  LITTLE_ENDIAN = 1

  DOUBLE_BYTESIZE = 8
  UINT32_BYTESIZE = 4

  POINT_TYPE = 1
  POLYGON_TYPE = 3

  UNIT_METER = 'metre'
  UNIT_MILE = 'mile'

  WGS84 = 4326

  module_function

  def st_geomfromtext(geometry, srid: WGS84)
    value = Arel::Nodes::Quoted.new(geometry.to_wkt)
    srid = Arel::Nodes::Quoted.new(srid)

    Arel::Nodes::NamedFunction.new('ST_GEOMFROMTEXT', [value, srid])
  end
end
