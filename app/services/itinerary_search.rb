# frozen_string_literal: true

class ItinerarySearch
  SEARCH_RADIUS_METERS = 5000
  GEO_WHERE_CONDITION = 'ST_DWithin(start_location, Geography(ST_MakePoint(:start_lon, :start_lat)), :search_meters) AND ST_DWithin(end_location, Geography(ST_MakePoint(:end_lon, :end_lat)), :search_meters)'

  def self.call(params, user)
    new(params, user)
  end

  def initialize(params, user)
    @params = params
    @user = user
    @now = Time.now.utc
  end

  def itineraries
    start_location = params.values_at(:start_location_lng, :start_location_lat).map(&:to_f)
    end_location = params.values_at(:end_location_lng, :end_location_lat).map(&:to_f)

    # Apply non-geographical filters
    filters = extract_filters_from_params
    itineraries = Itinerary.includes(:user).where(filters)

    # Get itineraries from A to B
    from_a_to_b_itineraries = itineraries.where(*geographic_conditions(start_location, end_location)).where('leave_date >= ?', now)

    # Get itineraries from B to A, unless passenger searched for a round trip
    # NOTE: Think about it - driver may need a travelmate for the whole trip
    from_b_to_a_itineraries = filters[:round_trip] ? itineraries.none : itineraries.where(*geographic_conditions(end_location, start_location)).where('return_date >= ?', now)

    from_a_to_b_itineraries.or(from_b_to_a_itineraries)
  end

  private

  attr_reader :params, :user, :now

  def geographic_conditions(start_location, end_location, search_radius_meters = SEARCH_RADIUS_METERS)
    [GEO_WHERE_CONDITION, { start_lon: start_location[0], start_lat: start_location[1], end_lon: end_location[0], end_lat: end_location[1], search_meters: search_radius_meters }]
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
      param = params[:"filter_#{checkbox_field}"]
      filters[checkbox_field] = true if param == '1'
    end

    # Limit pink filter to female users
    filters[:pink] = false unless user.female?
  end

  def add_boolean_filters(filters)
    %i[smoking_allowed pets_allowed].each do |boolean_field|
      param = params[:"filter_#{boolean_field}"]
      filters[boolean_field] = (param == 'true') if param.present?
    end
  end

  def add_gender_filter(filters)
    filter_driver_gender_param = params[:filter_driver_gender]
    filters[:driver_gender] = filter_driver_gender_param if User::GENDER.include?(filter_driver_gender_param)
  end
end
