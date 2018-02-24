# frozen_string_literal: true

class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  # TODO: False positive ref: bbatsov/rubocop#5236
  # rubocop:disable Rails/InverseOf
  belongs_to :sender, class_name: User.model_name.to_s
  # rubocop:enable Rails/InverseOf

  embedded_in :conversation

  field :body
  field :read_at, type: DateTime

  validates :body, presence: true, length: { maximum: 1000 }
  validates :sender, presence: true

  scope(:unread, -> { where(read_at: nil) })

  def unread?
    read_at.nil?
  end
end
