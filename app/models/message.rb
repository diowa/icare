# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'

  validates :body, presence: true, length: { maximum: 1000 }
  validates :sender, presence: true
  validates :conversation, presence: true

  scope :unread, -> { where(read_at: nil) }

  def unread?
    read_at.nil?
  end
end
