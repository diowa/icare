# frozen_string_literal: true

json.call(itinerary, :description, :fuel_cost, :leave_date, :num_people, :overview_polyline,
          :pets_allowed, :daily, :return_date, :round_trip, :smoking_allowed, :pink,
          :title, :tolls, :via_waypoints)

json.id itinerary.id.to_s
json.start_location itinerary.start_location.to_latlng_hash
json.end_location itinerary.end_location.to_latlng_hash

json.url itinerary_url(itinerary)

json.user do
  json.call(itinerary.user, :name, :uid, :to_param, :facebook_verified)

  # TODO: move to front-end
  json.image itinerary.user.image? ? itinerary.user.image : image_path('user.jpg')
end
