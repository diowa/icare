class BetaInvite
  include Mongoid::Document

  attr_accessible :email

  field :email

  validates :email, uniqueness: true, format: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/

end