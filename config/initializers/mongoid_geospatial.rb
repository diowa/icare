if defined?(Mongoid::Geospatial)
  Mongoid::Geospatial.use_rgeo

  # OK. x and y are intelligible but I'm dumb and I need :lat and :lng
  module Mongoid
    module Geospatial
      class Point
        alias :lat :y
        alias :lng :x
      end
    end
  end
end
