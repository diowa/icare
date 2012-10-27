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

  scope :positives, where(:"references_incoming.rating" => 1)
  scope :neutrals, where(:"references_incoming.rating" => 0)
  scope :negatives, where(:"references_incoming.rating" => -1)

  validates :itinerary, uniqueness: { scope: :referencing_user_id, message: :already_present }
  validate :not_by_myself

  def not_by_myself
    self.errors.add(:user, :yourself) if user.id == referencing_user_id
  end

  def self.build_from_params(params, user, itinerary)
    reference = user.references.build(params)
    reference.itinerary = itinerary
    reference.referencing_user_id = itinerary.user.id
    reference.read = Time.now.utc
    reference
  end

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
