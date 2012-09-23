class Notifications::Reference < Notification
=begin
  field :actor_id, type: BSON::ObjectId
  field :reference_id, type: BSON::ObjectId
  field :relevant, type: Boolean
  field :is_new, type: Boolean

  def translation_key
    if !relevant?
      'notifications.reference_not_relevant'
    else
      if is_new?
        'notifications.reference_created'
      else
        'notifications.reference_updated'
      end
    end
  end
=end
end
