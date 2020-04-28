# frozen_string_literal: true

module Spatial
  class Geometry
    def to_hex
      to_wkb.unpack1('H*')
    end
  end
end
