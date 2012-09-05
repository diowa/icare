class Notifications::HospitalityOutgoingInvite < Notification
  field :actor_id, type: BSON::ObjectId
  field :outgoing_invite_id, type: BSON::ObjectId
  field :inquiry, type: Boolean
  field :message_only, type: Boolean

  def translation_key
    if message_only?
      'notifications.hospitality_outgoing_invite_message_received'
    else
      'notifications.hospitality_outgoing_invite_updated'
    end
  end

  def outgoing_invite
    @outgoing_invite ||= user.hospitality_outgoing_invites.find(outgoing_invite_id)
  end
end
