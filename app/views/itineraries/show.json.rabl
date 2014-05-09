object @itinerary

attributes :description, :fuel_cost, :leave_date, :num_people, :overview_polyline,
           :pets_allowed, :daily, :return_date, :round_trip, :smoking_allowed, :pink,
           :title, :tolls, :vehicle, :via_waypoints

node(:id) { |itinerary| itinerary.id.to_s }
node(:start_location) { |itinerary| itinerary.start_location.to_latlng_hash }
node(:end_location) { |itinerary| itinerary.end_location.to_latlng_hash }

node(:url) { |itinerary| itinerary_url(itinerary) }

child :user do
  attributes :name, :uid, :to_param, :profile_picture, :facebook_verified
end
