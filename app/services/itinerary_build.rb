class ItineraryBuild
  def initialize(params, user)
    @params = params
    @user = user
  end

  def itinerary
    @itinerary ||= build @params, @user
  end

  private
  def build(params, user)
    Itinerary.new(params) do |itinerary|
      set_route_fields itinerary

      itinerary.user = @user

      # Caching some data
      itinerary.driver_gender = @user.gender
      itinerary.verified = @user.facebook_verified
    end
  end

  def set_route_fields(itinerary)
    route_json_object = JSON.parse(@params[:route_json_object]) rescue return
    itinerary.start_location    = { lat: route_json_object['start_location']['lat'],
                                    lng: route_json_object['start_location']['lng'] } if route_json_object['start_location']
    itinerary.end_location      = { lat: route_json_object['end_location']['lat'],
                                    lng: route_json_object['end_location']['lng'] } if route_json_object['end_location']
    itinerary.via_waypoints     = route_json_object['via_waypoints']
    itinerary.overview_path     = route_json_object['overview_path']
    itinerary.overview_polyline = route_json_object['overview_polyline']
  end
end
