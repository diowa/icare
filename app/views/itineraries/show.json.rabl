object @itinerary

attributes :id, :description, :fuel_cost, :leave_date, :num_people, :overview_polyline,
           :pets_allowed, :daily, :return_date, :round_trip, :smoking_allowed,
           :title, :tolls, :vehicle, :via_waypoints

node(:start_location) { |itinerary| itinerary.to_latlng_hash(:start_location) }
node(:end_location) { |itinerary| itinerary.to_latlng_hash(:end_location) }

node(:url) { |itinerary| itinerary_url(itinerary) }

child :user do
  attributes :name, :uid, :nationality, :to_param, :profile_picture
end
