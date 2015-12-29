module References
  class Outgoing < Base
    embedded_in :reference

    after_save do
      # Notifications and Incoming Reference
      if changed?
        other_user = User.find reference.referencing_user_id
        other_reference = other_user.references.where(itinerary_id: reference.itinerary.id,
                                                      referencing_user_id: reference.user.id).first_or_initialize
        other_reference.user = other_user # NOTE first_or_initialize doesn't set the user
        other_reference.build_incoming rating: rating, body: body
        other_reference.save
      end
    end
  end
end
