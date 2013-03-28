class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  # Concerns
  include ::Concerns::User::Authentication
  include ::Concerns::User::Facebook

  GENDER = %w(male female)

  paginates_per 25

  index({ username_or_uid: 1 })

  has_and_belongs_to_many :conversations

  has_many :itineraries, dependent: :destroy
  has_many :feedbacks

  embeds_many :notifications
  embeds_many :references, cascade_callbacks: true

  # Auth / Credentials / Permissions
  field :provider
  field :uid
  field :oauth_token
  field :oauth_expires_at
  field :facebook_permissions, type: Array, default: []

  # Cached Facebook data
  field :facebook_friends, type: Array, default: []
  field :facebook_favorites, type: Array, default: []
  field :facebook_data_cached_at, type: DateTime, default: '2012-09-06'

  # Info
  field :email
  field :name
  field :facebook_verified, type: Boolean, default: false

  # Extra
  field :username
  field :gender
  field :bio
  field :languages, type: Array, default: []

  # More info requiring special permissions
  field :birthday, type: Date
  field :work, type: Hash, default: {}
  field :education, type: Hash, default: {}

  # Icare
  field :username_or_uid
  field :vehicle_avg_consumption, type: Float, default: (1.741*7.0/100.0).round(2)

  # Account
  field :locale
  field :time_zone, default: 'UTC' # NOTE think about it
  field :telephone
  field :admin, type: Boolean, default: false

  #field :access_level, type: Integer, default: 0
  field :banned, type: Boolean, default: false

  field :send_email_messages, type: Boolean, default: false
  field :send_email_references, type: Boolean, default: false

  validates :gender, inclusion: GENDER, allow_blank: true
  validates :time_zone, inclusion: ActiveSupport::TimeZone.zones_map(&:name).keys, allow_blank: true
  validates :vehicle_avg_consumption, numericality: { greater_than: 0, less_than: 10 }, presence: true
  #validates :access_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }


  def age
    ((Time.now.to_s(:number).to_i - birthday.to_time.to_s(:number).to_i) / 10e9.to_i) if birthday?
  end

  def first_name
    @first_name ||= name.split[0] if name?
  end

  def to_s
    name || id
  end

  def to_param
    username || uid || id
  end

  def profile_picture(type = 'square')
    "http://graph.facebook.com/#{uid}/picture?type=#{type}"
  end

  def unread_conversations_count
    conversations.unread(self).size
  end

  def unread_references_count
    references.unread.size
  end

  def male?
    gender == 'male'
  end

  def female?
    gender == 'female'
  end
end
