class ItinerarySearch
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :from, :to
  attr_accessor :start_location_lat, :start_location_lng, :end_location_lat, :end_location_lng
  attr_accessor :filter_smoking_allowed, :filter_pets_allowed, :filter_round_trip
  attr_accessor :filter_driver_gender

  validates :from, presence: true
  validates :to, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
