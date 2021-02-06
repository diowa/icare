# frozen_string_literal: true

json.call(itinerary, :description, :fuel_cost, :leave_date, :num_people, :overview_polyline,
          :pets_allowed, :daily, :return_date, :round_trip, :smoking_allowed, :pink,
          :title, :tolls, :via_waypoints)

json.id itinerary.id.to_s
json.start_location lat: itinerary.start_location.lat, lng: itinerary.start_location.lon
json.end_location lat: itinerary.end_location.lat, lng: itinerary.end_location.lon

json.url itinerary_url(itinerary)

json.user do
  json.call(itinerary.user, :name, :uid, :to_param)

  # TODO: move to front-end
  json.image itinerary.user.image? ? itinerary.user.image : asset_pack_path('media/images/user.jpg')
end
