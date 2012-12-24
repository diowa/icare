class ItinerarySearchService
  def initialize(params, user)
    @params = params
    @user = user
  end

  def itineraries
    # TODO: Optimization
    start_location = [@params[:start_location_lng].to_f, @params[:start_location_lat].to_f]
    end_location = [@params[:end_location_lng].to_f, @params[:end_location_lat].to_f]
    sphere_radius = 5.fdiv Mongoid::Geospatial.earth_radius[:km]

    # Apply filters
    filters = extract_filters_from_params
    itineraries = Itinerary.where(filters).includes(:user)

    # Filter pink itineraries. NOTE: it must be applied AFTER other filters
    itineraries = itineraries.where(pink: false) if @user.male?

    # From start to end
    normal_itineraries = itineraries.within_spherical_circle(start_location: [ start_location, sphere_radius ]) &
                         itineraries.within_spherical_circle(end_location: [ end_location, sphere_radius ])

    # From end to start, unless passenger searched for a round trip
    # NOTE: Think about it, because driver may need a travelmate for the whole trip
    reversed_itineraries = []
    unless filters[:round_trip]
      reversed_itineraries = itineraries.where(round_trip: true).within_spherical_circle(start_location: [ end_location, sphere_radius ]) &
                             itineraries.within_spherical_circle(end_location: [ start_location, sphere_radius ])
    end

    # Sum results
    normal_itineraries + reversed_itineraries
  rescue
    {}
  end

  private
  def extract_filters_from_params
    filters = {}

    [:round_trip, :pink, :verified].each do |checkbox_field|
      param = @params["filter_#{checkbox_field}".to_sym]
      filters.merge!(checkbox_field => true) if param == '1'
    end

    [:smoking_allowed, :pets_allowed].each do |boolean_field|
      param = @params["filter_#{boolean_field}".to_sym]
      filters.merge!(boolean_field => (param == 'true')) unless param.blank?
    end

    filter_driver_gender_param = @params[:filter_driver_gender]
    filters.merge!(driver_gender: filter_driver_gender_param) if User::GENDER.include?(filter_driver_gender_param)
    filters
  end
end
