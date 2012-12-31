class ItinerarySearch
  SPHERE_RADIUS = 5.fdiv Mongoid::Geospatial.earth_radius[:km]

  def initialize(params, user)
    @params = params
    @user = user
  end

  def itineraries
    # TODO: Optimization
    a_location = [@params[:start_location_lng].to_f, @params[:start_location_lat].to_f]
    b_location = [@params[:end_location_lng].to_f, @params[:end_location_lat].to_f]

    # Applying filters
    filters = extract_filters_from_params
    itineraries = Itinerary.includes(:user).where(filters)

    # Getting itineraries from A to B
    from_a_to_b_itineraries = itineraries.within_spherical_circle(start_location: [ a_location, SPHERE_RADIUS ]) \
                              & itineraries.within_spherical_circle(end_location: [ b_location, SPHERE_RADIUS ])

    # From B to A, unless passenger searched for a round trip
    # NOTE: Think about it - driver may need a travelmate for the whole trip
    from_b_to_a_itineraries = filters[:round_trip] ? [] : get_reversed(itineraries, a_location, b_location)

    # Sum results
    from_a_to_b_itineraries + from_b_to_a_itineraries
  rescue
    []
  end

  private
  def get_reversed(itineraries, a_location, b_location)
    itineraries.where(round_trip: true).within_spherical_circle(start_location: [ b_location, SPHERE_RADIUS ]) \
    & itineraries.within_spherical_circle(end_location: [ a_location, SPHERE_RADIUS ])
  end

  def extract_filters_from_params
    filters = {}

    [:round_trip, :pink, :verified].each do |checkbox_field|
      param = @params["filter_#{checkbox_field}".to_sym]
      filters.merge!(checkbox_field => true) if param == '1'
    end

    # Overrides pink filter for malicious male users
    filters.merge!(pink: false) if @user.male?

    [:smoking_allowed, :pets_allowed].each do |boolean_field|
      param = @params["filter_#{boolean_field}".to_sym]
      filters.merge!(boolean_field => (param == 'true')) unless param.blank?
    end

    filter_driver_gender_param = @params[:filter_driver_gender]
    filters.merge!(driver_gender: filter_driver_gender_param) if User::GENDER.include?(filter_driver_gender_param)
    filters
  end
end
