# frozen_string_literal: true

class ItinerarySearch
  SEARCH_RADIUS_METERS = 5000
  GEO_WHERE_CONDITION = 'ST_DWithin(start_location, Geography(ST_MakePoint(:start_lon, :start_lat)), :search_meters) AND ST_DWithin(end_location, Geography(ST_MakePoint(:end_lon, :end_lat)), :search_meters)'

  def initialize(params, user)
    @params = params
    @user = user
    @now = Time.now.utc
  end

  def itineraries
    # OPTIMIZE
    start_location = [@params[:start_location_lng].to_f, @params[:start_location_lat].to_f]
    end_location = [@params[:end_location_lng].to_f, @params[:end_location_lat].to_f]

    # Applying filters
    filters = extract_filters_from_params
    itineraries = Itinerary.includes(:user).where(filters)

    # Getting itineraries from A to B
    from_a_to_b_itineraries = geographic_filtered_itineraries(itineraries, start_location, end_location).where('leave_date >= ?', @now)

    # From B to A, unless passenger searched for a round trip
    # NOTE: Think about it - driver may need a travelmate for the whole trip
    from_b_to_a_itineraries = filters[:round_trip] ? [] : geographic_filtered_itineraries(itineraries, end_location, start_location).where('return_date >= ?', @now)

    # Sum results
    from_a_to_b_itineraries + from_b_to_a_itineraries
  end

  private

  def geographic_filtered_itineraries(itineraries, start_location, end_location, search_radius_meters = SEARCH_RADIUS_METERS)
    itineraries.where GEO_WHERE_CONDITION, start_lon: start_location[0], start_lat: start_location[1], end_lon: end_location[0], end_lat: end_location[1], search_meters: search_radius_meters
  end

  def extract_filters_from_params
    filters = {}

    add_checkbox_filters(filters)
    add_boolean_filters(filters)
    add_gender_filter(filters)

    filters
  end

  def add_checkbox_filters(filters)
    %i[round_trip pink].each do |checkbox_field|
      param = @params["filter_#{checkbox_field}".to_sym]
      filters[checkbox_field] = true if param == '1'
    end

    # Overrides pink filter for malicious male users
    filters[:pink] = false unless @user.female?
  end

  def add_boolean_filters(filters)
    %i[smoking_allowed pets_allowed].each do |boolean_field|
      param = @params["filter_#{boolean_field}".to_sym]
      filters[boolean_field] = (param == 'true') if param.present?
    end
  end

  def add_gender_filter(filters)
    filter_driver_gender_param = @params[:filter_driver_gender]
    filters[:driver_gender] = filter_driver_gender_param if User::GENDER.include?(filter_driver_gender_param)
  end
end
