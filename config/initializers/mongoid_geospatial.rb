# frozen_string_literal: true

# Mongoid::Geospatial.with_rgeo!

# Monkey Patch Mongoid::Geospatial
# Add to_latlng_hash method
# Add :lat, :lng and to_latlng_a aliases
module Mongoid
  module Geospatial
    class Point
      alias lat y
      alias lng x

      alias to_latlng_a reverse

      def to_latlng_hsh
        { lat: y, lng: x }
      end
      alias to_latlng_hash to_latlng_hsh
    end
  end
end
