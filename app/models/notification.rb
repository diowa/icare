class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  embedded_in :user

  field :read_at, type: DateTime

  scope :unread, -> { where(read_at: nil) }
end
