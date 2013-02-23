class PermittedParams < Struct.new(:params, :current_user)
  def itinerary
    params.require(:itinerary).permit(*itinerary_attributes)
  end

  def itinerary_attributes
    basic_fields = [:title, :description, :vehicle, :num_people, :smoking_allowed, :pets_allowed, :fuel_cost, :tolls,
                    :round_trip, :leave_date, :return_date, :daily,
                    :route, :share_on_facebook_timeline]
    if current_user && current_user.female?
      basic_fields + [:pink]
    else
      basic_fields
    end
  end

  def user
    params.require(:user).permit(*user_attributes)
  end

  def user_attributes
    [:time_zone, :locale, :vehicle_avg_consumption]
  end
end
