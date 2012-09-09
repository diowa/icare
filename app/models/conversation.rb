class Conversation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  #attr_accessible :messages_attributes

  embeds_many :messages, cascade_callbacks: true
  #accepts_nested_attributes_for :messages, reject_if: ->(attributes) { attributes['body'].blank? }

  has_and_belongs_to_many :users
  belongs_to :conversable, polymorphic: true

  scope :unread, ->(user) { where(messages: { "$elemMatch" => { read: nil, sender_id: { "$ne" => user.id } } }) }

  validates :user_ids, uniqueness: { scope: [ :conversable_id, :conversable_type ] }

  def unread?(user)
    messages.where(read: nil, :sender_id.ne => user.id).size > 0
  end

  def users_except(user)
    users.reject{ |u| u == user }
  end

  def mark_as_read(user)
    messages.unread.where(:sender_id.ne => user.id).update_all(read: Time.now.utc)
  end

  def last_unread_message(user)
    messages.unread.where(:sender_id.ne => user.id).desc(:created_at).limit(1).first
  end
end
