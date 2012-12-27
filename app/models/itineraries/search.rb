class Itineraries::Search < Itineraries::Route
  attr_accessor :start_location_lat, :start_location_lng, :end_location_lat, :end_location_lng
  attr_accessor :filter_round_trip, :filter_pink, :filter_verified
  attr_accessor :filter_smoking_allowed, :filter_pets_allowed
  attr_accessor :filter_driver_gender
end
