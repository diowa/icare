# frozen_string_literal: true

class Message
=begin
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  belongs_to :sender, class_name: 'User'

  embedded_in :conversation

  field :body
  field :read_at, type: DateTime

  validates :body, presence: true, length: { maximum: 1000 }
  validates :sender, presence: true

  scope(:unread, -> { where(read_at: nil) })

  def unread?
    read_at.nil?
  end
=end
end
