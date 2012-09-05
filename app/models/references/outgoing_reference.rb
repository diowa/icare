class Reference::Outgoing < Reference

  embedded_in :incoming_reference

  validates :message, presence: true, on: :update, if: ->{ content_required }
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 1 }, if: ->{ content_required }
  validate :doable?, on: :update

  attr_accessor :content_required

  set_callback(:update, :after) do
    @is_new = !incoming_reference.related_reference.message?
    incoming_reference.related_reference.update_attributes(message: message,
                                                           rating: rating,
                                                           relevant: relevant)
  end

  set_callback(:save, :after) do
    # Notifications
    if changed?
      notification = Notifications::Reference.new(actor_id: incoming_reference.user.id,
                                                  reference_id: incoming_reference.related_reference_id,
                                                  relevant: relevant,
                                                  is_new: @is_new)
      incoming_reference.referencing_user.notifications << notification
    end
  end

  def doable?
    if changed? && !incoming_reference.visible?
      self.errors.add(:base, "You cannot leave a reference now")
    end
  end
end
