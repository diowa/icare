object @itinerary

attributes :id, :description, :end_location, :fuel_cost, :leave_date, :num_people, :overview_polyline,
           :pets_allowed, :daily, :return_date, :round_trip, :smoking_allowed, :start_location,
           :title, :tolls, :vehicle, :via_waypoints

node(:url) { |itinerary| itinerary_url(itinerary) }

child :user do
  attributes :name, :uid, :nationality, :to_param, :profile_picture
end
