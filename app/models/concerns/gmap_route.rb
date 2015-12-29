module Concerns
  module GmapRoute
    extend ActiveSupport::Concern

    included do
      include Mongoid::Geospatial

      BOUNDARIES = [APP_CONFIG.itineraries.bounds.sw, APP_CONFIG.itineraries.bounds.ne]

      # Route from Google Directions Service
      field :start_address
      field :end_address
      field :start_location, type: Mongoid::Geospatial::Point, spatial: true
      field :end_location, type: Mongoid::Geospatial::Point, spatial: true
      field :via_waypoints, type: Array
      field :overview_path, type: Mongoid::Geospatial::Line
      field :overview_polyline, type: String
      field :avoid_highways, type: Boolean, default: false
      field :avoid_tolls, type: Boolean, default: false

      attr_accessor :route

      validates :start_address, presence: true
      validates :end_address, presence: true
      validates :start_location, presence: true
      validates :end_location, presence: true
      validates :overview_polyline, presence: true

      validate :inside_bounds, if: -> { APP_CONFIG.itineraries.geo_restricted }, on: :create

      def inside_bounds
        errors.add(:base, :out_of_boundaries) unless point_inside_bounds?(start_location) && point_inside_bounds?(end_location)
      end

      def route=(param)
        json_route = JSON.parse(param)
        self.start_location, self.end_location,
          self.via_waypoints, self.overview_path,
            self.overview_polyline = json_route.values_at('start_location', 'end_location', 'via_waypoints', 'overview_path', 'overview_polyline')
      rescue
        nil
      end

      def sample_path(precision = 10)
        overview_path.in_groups(precision).map(&:first).insert(-1, overview_path.last).compact
      end

      def static_map(width = 640, height = 360)
        URI.encode("http://maps.googleapis.com/maps/api/staticmap?size=#{width}x#{height}&scale=2&sensor=false&markers=color:green|label:B|#{end_location.to_latlng_a.join(',')}&markers=color:green|label:A|#{start_location.to_latlng_a.join(',')}&path=enc:#{overview_polyline}")
      end

      private

      def point_inside_bounds?(point)
        # TODO: RGeo???
        point.lat.between?(BOUNDARIES[0][0], BOUNDARIES[1][0]) && point.lng.between?(BOUNDARIES[0][1], BOUNDARIES[1][1])
      end
    end
  end
end
