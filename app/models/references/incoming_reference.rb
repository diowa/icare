class Reference::Incoming < Reference

  embedded_in :user

  embeds_one :outgoing_reference
  accepts_nested_attributes_for :outgoing_reference

  attr_accessible :experience_class, :experience_id, :related_reference_id, :visible_from

  field :experience_class
  field :experience_id, type: BSON::ObjectId
  field :visible_from, type: Date
  field :related_reference_id, type: BSON::ObjectId

  validates :related_reference_id, presence: true, on: :create

  scope :visible, -> { where(:visible_from.lte => Date.today.midnight.utc) }

  scope :filled_up, where(:message.ne => nil, :rating.ne => nil, relevant: true)

  scope :hospitalities, where(experience_class: /^Hospitality/)

  scope :pending, -> { where( :"outgoing_reference.message" => nil, :"outgoing_reference.rating" => nil, :"outgoing_reference.relevant" => true) }
  scope :filled_up_by_me, -> { where( :"outgoing_reference.message".ne => nil, :"outgoing_reference.rating".ne => nil, :"outgoing_reference.relevant" => true) }

  scope :positive, where(rating: 1)
  scope :neutral, where(rating: 0)
  scope :negative, where(rating: -1)

  def related_reference
    @related_reference ||= referencing_user.references.find(related_reference_id)
  end

  def is_guest
    @is_guest ||= (experience_class == HospitalityRequest.model_name)
  end

  def is_host
    @is_host ||= (experience_class == HospitalityOutgoingInvite.model_name)
  end

  def hospitality?
    (experience_class == HospitalityRequest.model_name) || (experience_class == HospitalityOutgoingInvite.model_name)
  end

  def visible?
    Date.today.midnight.utc >= visible_from.at_midnight.utc
  end
end
