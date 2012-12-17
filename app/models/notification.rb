class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  embedded_in :user

  field :read, type: Boolean, default: false

  scope :unread, where(read: false)
end
