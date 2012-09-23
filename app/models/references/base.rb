class References::Base
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  attr_accessible :message, :rating

  field :message
  field :rating, type: Integer

  validates :message, presence: true
  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 1 }
end
