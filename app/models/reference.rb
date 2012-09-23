class Reference
  include Mongoid::Document

  belongs_to :itinerary

  belongs_to :referencing_user, class_name: User.model_name

  embedded_in :user

  embeds_one :incoming_reference
  embeds_one :outgoing_reference

  scope :positive, where(:"incoming_reference.rating" => 1)
  scope :neutral, where(:"incoming_reference.rating" => 0)
  scope :negative, where(:"incoming_referenc.rating" => -1)

  def driver?
    itinerary.user_id == user.id
  end
end
