# frozen_string_literal: true

class Conversation < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  has_many :messages, dependent: :destroy

  belongs_to :conversable, polymorphic: true

  has_and_belongs_to_many :users

  scope :unread, lambda { |user|
    joins(:messages).where(messages: { read_at: nil }).where.not(messages: { sender: user })
  }

  validates :sender, uniqueness: { scope: %i[conversable_id conversable_type receiver_id], message: :already_exists }
  validate :no_self_conversation

  def last_unread_message(user)
    messages.unread.where.not(sender: user).order(created_at: :desc).limit(1).first
  end

  def mark_as_read!(user)
    messages.unread.where.not(sender: user).touch_all :read_at
  end

  def participants
    [sender, receiver]
  end

  def participates?(user)
    participants.include? user
  end

  def unread?(user)
    messages.unread.where.not(sender: user).any?
  end

  def with(user)
    sender == user ? receiver : sender
  end

  private

  def no_self_conversation
    errors.add(:receiver, :yourself) if sender == receiver
  end
end
