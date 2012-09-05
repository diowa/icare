class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  attr_accessible :body, :sender, :read

  belongs_to :sender, class_name: User.model_name

  embedded_in :conversation

  field :body
  field :read, type: DateTime, default: nil

  validates :body, presence: true, length: { maximum: 1000 }
  validates :sender, presence: true

  scope :unread, where(read: nil)

  def unread?
    read.nil?
  end
end
