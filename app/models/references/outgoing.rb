class References::Outgoing < References::Base

  embedded_in :reference

  set_callback(:save, :after) do
    # Notifications and Incoming Reference
    if changed?
      other_user = reference.itinerary.user
      other_reference = other_user.references.where(itinerary: reference.itinerary,
                                                   referencing_user_id: reference.user.id).first || other_user.references.build
      other_reference.itinerary_id = reference.itinerary
      other_reference.referencing_user_id = reference.user.id
      other_reference.build_references_incoming(rating: rating, body: body)
      other_user.save
    end
  end
end
