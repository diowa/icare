class Itinerary
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::Geospatial
  include Mongoid::MultiParameterAttributes
  include Mongoid::Slug

  VEHICLE = %w(car motorcycle van)
  DAYNAME = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
  BOUNDARIES = [APP_CONFIG.itineraries.bounds.sw, APP_CONFIG.itineraries.bounds.ne]

  attr_accessible :title, :description, :vehicle, :num_people, :smoking_allowed, :pets_allowed, :fuel_cost, :tolls, :pink
  attr_accessible :round_trip, :leave_date, :return_date, :daily
  attr_accessible :share_on_facebook_timeline

  belongs_to :user
  delegate :name, to: :user, prefix: true
  delegate :first_name, to: :user, prefix: true

  has_many :conversations, as: :conversable, dependent: :destroy

  # Route
  field :start_location, type: Point, spatial: true
  field :end_location, type: Point, spatial: true
  field :via_waypoints, type: Array
  field :overview_path, type: Line
  field :overview_polyline, type: String

  # Details
  field :title
  field :description
  field :vehicle, default: 'car'
  field :num_people, type: Integer
  field :smoking_allowed, type: Boolean, default: false
  field :pets_allowed, type: Boolean, default: false
  field :fuel_cost, type: Integer
  field :tolls, type: Integer
  field :pink, type: Boolean, default: false
  field :round_trip, type: Boolean, default: false
  field :leave_date, type: DateTime
  field :return_date, type: DateTime
  field :daily, type: Boolean, default: false

  # Cached user details (for filtering purposes)
  field :driver_gender
  field :verified

  attr_accessor :route, :share_on_facebook_timeline

  slug :title, reserve: %w(new)

  #default_scope -> { any_of({:leave_date.gte => Time.now.utc}, {:return_date.gte => Time.now.utc, round_trip: true}, { daily: true }) }

  validates :start_location, presence: true
  validates :end_location, presence: true
  validates :title, length: { maximum: 40 }, presence: true
  validates :description, length: { maximum: 1000 }, presence: true
  validates :vehicle, inclusion: VEHICLE
  validates :num_people, numericality: { only_integer: true, greater_than: 0, less_than: 10 }, allow_blank: true
  validates :fuel_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 10000 }
  validates :tolls, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 10000 }
  validate :driver_is_female, if: -> { pink }

  validates :leave_date, timeliness: { on_or_after: -> { Time.now } }, on: :create
  validate :inside_bounds, if: -> { APP_CONFIG.itineraries.geo_restricted }, on: :create
  validate :return_date_validator, if: -> { round_trip }

  def return_date_validator
    self.errors.add(:return_date,
                    I18n.t('mongoid.errors.messages.after',
                    restriction: leave_date.strftime(I18n.t('validates_timeliness.error_value_formats.datetime')))) if return_date <= leave_date
  end

  def driver_is_female
    self.errors.add(:pink, :driver_must_be_female) unless user.female?
  end

  def inside_bounds
    self.errors.add(:route, :out_of_boundaries) unless point_inside_bounds?(start_location) && point_inside_bounds?(end_location)
  end

  def sample_path(precision = 10)
    # TODO move outside model
    overview_path.in_groups(precision).map { |g| g.first }.insert(-1,overview_path.last)
  end

  def static_map
    URI.encode("http://maps.googleapis.com/maps/api/staticmap?size=200x200&scale=2&sensor=false&markers=color:green|label:B|#{end_location.to_latlng_a.join(",")}&markers=color:green|label:A|#{start_location.to_latlng_a.join(",")}&path=enc:#{overview_polyline}")
  end

  def to_s
    title || id
  end

  private
  def point_inside_bounds?(point)
    # TODO RGeo???
    point.lat.between?(BOUNDARIES[0][0], BOUNDARIES[1][0]) && point.lng.between?(BOUNDARIES[0][1], BOUNDARIES[1][1])
  end

=begin
  def random_close_location(max_dist = 0.5, km = true)
    # TODO move outside model

    # Thanks to http://www.geomidpoint.com/random/calculation.html

    return unless source && source[:lat] != nil && source[:lng] != nil

    deg_to_rad = Math::PI / 180
    rad_to_deg = 180 / Math::PI
    radius_earth_M = 3960.056052
    radius_earth_Km = 6372.796924

    rand1 = rand
    rand2 = rand

    # Convert all latitudes and longitudes to radians
    start_lat = source[:lat] * deg_to_rad
    start_lng = source[:lng] * deg_to_rad

    # Convert maximum distance to radians.
    max_dist_rad = max_dist / (km ? radius_earth_Km : radius_earth_M)

    # Compute a random distance from 0 to maxdist scaled
    # so that points on larger circles have a greater probability
    # of being chosen than points on smaller circles as described earlier.
    dist = Math::acos( rand1 * (Math::cos(max_dist_rad) - 1) + 1 )

    # Compute a random bearing from 0 to 2*PI radians (0 to 360 degrees),
    # with all bearings having an equal probability of being chosen.
    brg = 2 * Math::PI * rand2

    # Use the starting point, random distance and random bearing to calculate the coordinates of the final random point.
    lat = Math::asin( Math::sin(start_lat) * Math::cos(dist) + Math::cos(start_lat) * Math::sin(dist) * Math::cos(brg) )
    lng = start_lng + Math::atan2( Math::sin(brg) * Math::sin(dist) * Math::cos(start_lat), Math::cos(dist) - Math::sin(start_lat) * Math.sin(lat) )

    if (lng < -1 * Math::PI)
      lng = lng + 2 * Math::PI
    elsif (lng > Math::PI)
      lng = lng - 2 * Math::PI
    end

    [lat * rad_to_deg, lng * rad_to_deg]
  end
=end
end
