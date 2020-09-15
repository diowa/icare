# frozen_string_literal: true

module GeoItinerary
  extend ActiveSupport::Concern

  RGEO_FACTORY = RGeo::Geographic.simple_mercator_factory(buffer_resolution: 4)
  LINEAR_RING = RGEO_FACTORY.linear_ring(APP_CONFIG.itineraries.bounds.map { |p| RGeo::Geographic.spherical_factory.point(*p) })

  included do
    attr_accessor :route

    validates :start_address, presence: true
    validates :end_address, presence: true
    validates :start_location, presence: true
    validates :end_location, presence: true
    validates :overview_polyline, presence: true

    validate :inside_bounds, if: -> { APP_CONFIG.itineraries.geo_restricted }, on: :create

    %i[start_location end_location].each do |geo_field|
      define_method :"#{geo_field}=" do |value|
        value = "POINT(#{value.join ' '})" if value.is_a?(Array)
        super value
      end
    end

    def overview_path=(value)
      value = "LINESTRING(#{value.map { |p| p.join(' ') }.join(', ')})" if value.is_a?(Array) && value.all? { |p| p.is_a?(Array) }
      super value
    end

    def via_waypoints=(value)
      value = "MULTIPOINT(#{value.map { |p| p.join(' ') }.join(', ')})" if value.is_a?(Array) && value.all? { |p| p.is_a?(Array) }
      super value
    end

    def inside_bounds
      errors.add(:base, :out_of_boundaries) unless LINEAR_RING.contains?(start_location) && LINEAR_RING.contains?(end_location)
    end

    def route=(param)
      json_route = JSON.parse(param)

      self.start_location    = json_route['start_location']
      self.end_location      = json_route['end_location']
      self.via_waypoints     = json_route['via_waypoints']
      self.overview_path     = json_route['overview_path']
      self.overview_polyline = json_route['overview_polyline']
    rescue
      nil
    end

    def sample_path(precision = 10)
      overview_path.coordinates.in_groups(precision).map(&:first).insert(-1, overview_path.coordinates.last).compact
    end

    def static_map(width = 640, height = 360)
      Addressable::URI.encode [
        "https://maps.googleapis.com/maps/api/staticmap?size=#{width}x#{height}",
        'scale=2',
        "markers=color:green|label:B|#{end_location.coordinates.reverse.join(',')}",
        "markers=color:green|label:A|#{start_location.coordinates.reverse.join(',')}",
        "path=enc:#{overview_polyline}",
        ("key=#{APP_CONFIG.google_maps_api_key}" if APP_CONFIG.google_maps_api_key)
      ].compact.join('&')
    end
  end
end
