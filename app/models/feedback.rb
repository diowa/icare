class Feedback
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPE = %w(bug idea)
  STATUS = ['open', 'fixed', 'in progress', 'not applicable']

  attr_accessible :type, :status, :message, :url

  belongs_to :user
  delegate :name, to: :user, prefix: true

  field :type, type: String
  field :message, type: String
  field :url, type: String
  field :status, type: String, default: 'open'

  validates :type, inclusion: TYPE, presence: true
  validates :status, inclusion: STATUS, presence: true
  validates :message, presence: true

  def short_message(max = 100)
    message.truncate(max)
  end

  def fixed?
    status == 'fixed'
  end
end
