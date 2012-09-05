class Conversation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  #attr_accessible :messages_attributes

  embeds_many :messages, cascade_callbacks: true
  #accepts_nested_attributes_for :messages, reject_if: ->(attributes) { attributes['body'].blank? }

  has_and_belongs_to_many :users
  belongs_to :conversable, polymorphic: true

  def mark_as_read(user)
    messages.unread.where(:sender_id.ne => user.id).update_all(read: Time.now.utc)
  end
end
