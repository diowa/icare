module Itineraries
  class Search
    include ::ActiveModel::Model

    attr_accessor :from, :to,
                  :start_location_lat, :start_location_lng, :end_location_lat, :end_location_lng,
                  :filter_round_trip, :filter_pink, :filter_verified, :filter_smoking_allowed, :filter_pets_allowed, :filter_driver_gender

    validates :from, presence: true
    validates :to, presence: true
  end
end
