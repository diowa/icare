class ItineraryBuild
  def initialize(params, user)
    @params = params
    @user = user
  end

  def itinerary
    @itinerary ||= build_from_route_json_object @params, @user
  end

  private
  def build_from_route_json_object(params, user)
    Itinerary.new(params) do |itinerary|
      route_json_object = JSON.parse(@params[:route_json_object])
      itinerary.start_location    = { lat: route_json_object['start_location']['lat'],
                                      lng: route_json_object['start_location']['lng'] }
      itinerary.end_location      = { lat: route_json_object['end_location']['lat'],
                                      lng: route_json_object['end_location']['lng'] }
      itinerary.via_waypoints     = route_json_object['via_waypoints']
      itinerary.overview_path     = route_json_object['overview_path']
      itinerary.overview_polyline = route_json_object['overview_polyline']

      itinerary.user = @user

      # Caching some data
      itinerary.driver_gender = @user.gender
      itinerary.verified = @user.facebook_verified
    end
  end
end
