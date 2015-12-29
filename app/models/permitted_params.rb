PermittedParams = Struct.new(:params, :current_user) do
  def itinerary
    params.require(:itinerary).permit(*itinerary_attributes)
  end

  def itinerary_attributes
    basic_fields = [:start_address, :end_address, :description, :num_people, :smoking_allowed, :pets_allowed, :fuel_cost, :tolls,
                    :avoid_highways, :avoid_tolls,
                    :round_trip, :leave_date, :return_date, :daily,
                    :route, :share_on_facebook_timeline]
    basic_fields << :pink if current_user && current_user.female?
    basic_fields
  end

  def user
    params.require(:user).permit(*user_attributes)
  end

  def user_attributes
    [:time_zone, :locale, :vehicle_avg_consumption]
  end

  def feedback
    params.require(:feedback).permit(*feedback_attributes)
  end

  def feedback_attributes
    basic_fields = [:type, :message, :url]
    basic_fields << :status if current_user && current_user.admin?
    basic_fields
  end

  def conversation
    params.require(:conversation).permit(*conversation_attributes)
  end

  def conversation_attributes
    [message: [:body]]
  end

  def reference
    params.require(:reference).permit(*reference_attributes)
  end

  def reference_attributes
    [:body, :rating]
  end
end
