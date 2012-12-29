if defined?(Mongoid::Geospatial)
  Mongoid::Geospatial.use_rgeo

  # Adding :lat and :lng aliases; to_latlng_a and to_latlng:hash methods
  module Mongoid
    module Geospatial
      class Point
        alias :lat :y
        alias :lng :x

        # TODO this needs proper testing
        def to_latlng_hsh
          { lat: y, lng: x }
        end
        alias :to_latlng_hash :to_latlng_hsh

        # TODO this needs proper testing
        def to_latlng_a
          [ y, x ]
        end
      end
    end
  end
end
