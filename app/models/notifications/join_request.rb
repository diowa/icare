class Notifications::JoinRequest < Notification
=begin
  field :actor_id, type: BSON::ObjectId
  field :request_id, type: BSON::ObjectId
  field :incoming_invite_id, type: BSON::ObjectId
  field :inquiry, type: Boolean
  field :message_only, type: Boolean
  field :is_new, type: Boolean

  def translation_key
    if message_only?
      'notifications.hospitality_request_message_received'
    elsif inquiry?
      if is_new?
        'notifications.hospitality_request_inquiry_received'
      else
        'notifications.hospitality_request_inquiry_updated'
      end
    else
      if is_new?
        'notifications.hospitality_request_invite_received'
      else
        'notifications.hospitality_request_invite_updated'
      end
    end
  end

  def request
    @request ||= user.hospitality_requests.find(request_id)
  end

  def incoming_invite
    @incoming_invite ||= @request.incoming_invites.find(incoming_invite_id)
  end
=end
end
