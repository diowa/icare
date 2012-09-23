class Reference
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :itinerary

  attr_accessible :references_outgoing

  embedded_in :user

  embeds_one :references_incoming, class_name: References::Incoming.model_name, cascade_callbacks: true
  embeds_one :references_outgoing, class_name: References::Outgoing.model_name, cascade_callbacks: true
  accepts_nested_attributes_for :references_outgoing

  field :referencing_user_id
  field :read, type: DateTime, default: nil

  scope :unread, where(read: nil)

  scope :positive, where(:"incoming_reference.rating" => 1)
  scope :neutral, where(:"incoming_reference.rating" => 0)
  scope :negative, where(:"incoming_referenc.rating" => -1)

  validates :itinerary, uniqueness: { scope: :referencing_user_id }

  def unread?
    !read
  end

  def driver?
    itinerary.user.id == referencing_user_id
  end

  def referencing_user
    User.where(_id: referencing_user_id).first
  end
end
