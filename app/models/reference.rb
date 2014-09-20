class Reference
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :itinerary

  embedded_in :user

  embeds_one :incoming, class_name: References::Incoming.model_name, cascade_callbacks: true
  embeds_one :outgoing, class_name: References::Outgoing.model_name, cascade_callbacks: true

  field :referencing_user_id
  field :read_at, type: DateTime

  attr_accessor :body, :rating

  scope :unread, -> { where(read_at: nil) }

  scope :positives, -> { where(:"incoming.rating" => 1) }
  scope :neutrals, -> { where(:"incoming.rating" => 0) }
  scope :negatives, -> { where(:"incoming.rating" => -1) }

  validates :referencing_user_id, uniqueness: { message: :already_present }
  validate :not_by_myself

  def not_by_myself
    self.errors.add(:user, :yourself) if user.id == referencing_user_id
  end

  def unread?
    read_at.nil?
  end

  def driver?
    itinerary.user.id == referencing_user_id
  end

  def referencing_user
    User.where(_id: referencing_user_id).first
  end
end
