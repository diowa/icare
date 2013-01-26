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
    overview_path.in_groups(precision).map { |g| g.first }.insert(-1, overview_path.last).compact
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
end
