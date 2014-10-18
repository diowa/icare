# TODO: Hopefully remove when https://github.com/mongoid/mongoid/issues/3767 will be fixed

module Origin
  module Selectable
    def within_spherical_circle(criterion = nil)
      __expanded__(criterion, "$geoWithin", "$centerSphere")
    end
    key :within_spherical_circle, :expanded, "$geoWithin", "$centerSphere"
  end
end
