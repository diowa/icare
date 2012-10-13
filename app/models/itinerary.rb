class Itinerary
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::Geospatial
  include Mongoid::MultiParameterAttributes
  include Mongoid::Slug

  index({ start_location: 1 }, { background: true })
  index({ end_location: 1 }, { background: true })

  VEHICLE = %w(car motorcycle van)
  DAYNAME = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

  attr_accessible :title, :description, :vehicle, :num_people, :smoking_allowed, :pets_allowed, :fuel_cost, :tolls
  attr_accessible :round_trip, :leave_date, :return_date
  attr_accessible :share_on_facebook_timeline

  belongs_to :user
  delegate :name, to: :user, prefix: true
  delegate :first_name, to: :user, prefix: true

  has_many :conversations, as: :conversable, dependent: :destroy

  # Route
  field :start_location, type: Point
  field :end_location, type: Point
  field :via_waypoints, type: Array
  field :overview_path, type: Array
  field :overview_polyline, type: String

  # Details
  field :title
  field :description
  field :vehicle, default: "car"
  field :num_people, type: Integer
  field :smoking_allowed, type: Boolean, default: false
  field :pets_allowed, type: Boolean, default: false
  field :fuel_cost, type: Integer
  field :tolls, type: Integer
  field :round_trip, type: Boolean, default: false
  field :leave_date, type: DateTime
  field :return_date, type: DateTime
  field :daily, type: Boolean, default: false

  # Cached user details (for filtering purposes)
  field :driver_gender

  attr_accessor :route_json_object, :share_on_facebook_timeline

  slug :title

  #default_scope -> { any_of({:leave_date.gte => Time.now.utc}, {:return_date.gte => Time.now.utc, round_trip: true}, { daily: true }) }
  scope :sorted_by_creation, desc(:created_at)

  validates :title, length: { maximum: 40 }, presence: true
  validates :description, length: { maximum: 1000 }, presence: true
  validates :vehicle, inclusion: VEHICLE
  validates :num_people, numericality: { only_integer: true, greater_than: 0, less_than: 10 }, allow_blank: true
  validates :fuel_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 10000 }
  validates :tolls, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 10000 }

  validates :leave_date, timeliness: { on_or_after: -> { Time.now } }, on: :create
  validate :return_date_validator, if: -> { round_trip }

  def return_date_validator
    self.errors.add(:return_date, I18n.t("mongoid.errors.messages.after", restriction: leave_date.strftime(I18n.t("validates_timeliness.error_value_formats.datetime")))) if return_date <= leave_date
  end

  def self.build_with_route_json_object(params, user)
    new(params) do |itinerary|
      route_json_object = JSON.parse(params[:route_json_object])
      itinerary.start_location = { lat: route_json_object["start_location"]["lat"],
                                   lng: route_json_object["start_location"]["lng"] }
      itinerary.end_location = { lat: route_json_object["end_location"]["lat"],
                                 lng: route_json_object["end_location"]["lng"] }
      itinerary.via_waypoints = route_json_object["via_waypoints"]
      itinerary.overview_path = route_json_object["overview_path"]
      itinerary.overview_polyline = route_json_object["overview_polyline"]

      itinerary.user = user

      itinerary.driver_gender = user.gender
    end
  end

  def self.search(params)
    # TODO: Optimization
    start_location = [params[:start_location_lng].to_f, params[:start_location_lat].to_f]
    end_location = [params[:end_location_lng].to_f, params[:end_location_lat].to_f]
    sphere_radius = 5.fdiv(Mongoid::Geospatial.earth_radius[:km])

    itineraries = Itinerary.where(get_boolean_filters(params)).includes(:user)
    # From start to end
    itineraries_start_start = itineraries.within_spherical_circle(start_location: [ start_location, sphere_radius ])
    itineraries_end_end = itineraries.within_spherical_circle(end_location: [ end_location, sphere_radius ])

    # From end to start
    itineraries_start_end = itineraries.within_spherical_circle(start_location: [ end_location, sphere_radius ])
    itineraries_end_start = itineraries.within_spherical_circle(end_location: [ start_location, sphere_radius ])

    # Intersect and join
    (itineraries_start_start & itineraries_end_end) + (itineraries_start_end & itineraries_end_start) 
  rescue
  end

  def to_latlng_array(field)
    self[field].to_a.reverse if self[field]
  end

  def to_latlng_hash(field)
    { lat: self.send(field).lat, lng: self.send(field).lng } if self[field]
  end

  def sample_path(precision = 10)
    overview_path.in_groups(precision).map{ |g| g.first }.insert(-1,overview_path.last)
  end

  def static_map
    URI.encode("http://maps.googleapis.com/maps/api/staticmap?size=200x200&sensor=false&markers=color:green|label:B|#{to_latlng_array(:end_location).join(",")}&markers=color:green|label:A|#{to_latlng_array(:start_location).join(",")}&path=enc:#{overview_polyline}")
  end

  def random_close_location(max_dist = 0.5, km = true)
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

  def to_s
    title || super()
  end

private
  def self.get_boolean_filters(params = {})
    filters = {}
    [:smoking_allowed, :pets_allowed, :round_trip].each do |boolean_field|
      param = params["filter_#{boolean_field}".to_sym]
      filters.merge!(boolean_field => (param == "true")) unless param.blank?
    end
    filter_driver_gender_param = params[:filter_driver_gender]
    filters.merge!(driver_gender: filter_driver_gender_param) if User::GENDER.include?(filter_driver_gender_param)
    filters
  end
end
