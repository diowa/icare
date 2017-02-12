# frozen_string_literal: true
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  # Concerns
  include ::Concerns::User::FacebookOmniauthable

  # Include default devise modules. Others available are:
  devise :omniauthable, omniauth_providers: [:facebook]
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :database_authenticatable, :registerable,
  # :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email, type: String, default: ''
  # field :encrypted_password, type: String, default: ""

  ## Recoverable
  # field :reset_password_token,   type: String
  # field :reset_password_sent_at, type: Time

  ## Rememberable
  # field :remember_created_at, type: Time

  ## Trackable
  # field :sign_in_count,      type: Integer, default: 0
  # field :current_sign_in_at, type: Time
  # field :last_sign_in_at,    type: Time
  # field :current_sign_in_ip, type: String
  # field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  ## Omniauthable
  field :provider
  field :uid

  # The gender selected by this person, male or female. This value will be omitted if the gender is set to a custom value
  # Ref: https://developers.facebook.com/docs/graph-api/reference/user/
  GENDER = %w(male female).freeze

  paginates_per 25

  has_and_belongs_to_many :conversations

  has_many :feedbacks
  has_many :itineraries, dependent: :destroy

  embeds_many :notifications
  embeds_many :references, cascade_callbacks: true

  # Uneditable user info
  field :bio,       type: String
  field :birthday,  type: Date
  field :education, type: Array, default: []
  field :gender,    type: String
  field :image,     type: String
  field :languages, type: Array, default: []
  field :name,      type: String
  field :work,      type: Array, default: []

  # Editable user info
  field :locale,                  type: String
  field :send_email_messages,     type: Boolean, default: false
  field :send_email_references,   type: Boolean, default: false
  field :telephone,               type: String
  field :time_zone,               type: String,  default: 'UTC'
  field :vehicle_avg_consumption, type: Float,   default: APP_CONFIG.fuel_consumption

  # Account status
  field :admin,  type: Boolean, default: false
  field :banned, type: Boolean, default: false

  validates :gender, inclusion: GENDER, allow_blank: true
  validates :time_zone, inclusion: ActiveSupport::TimeZone.all.map(&:name), allow_blank: true
  validates :vehicle_avg_consumption, numericality: { greater_than: 0, less_than: 10 }, presence: true

  def age
    ((Time.current.to_s(:number).to_i - birthday.at_midnight.to_s(:number).to_i) / 10e9.to_i) if birthday?
  end

  def female?
    gender == 'female'
  end

  def first_name
    @first_name ||= name.split[0] if name?
  end

  def to_s
    name || id
  end

  def unread_conversations_count
    conversations.unread(self).size
  end

  def unread_references_count
    references.unread.size
  end

  def self.from_omniauth(auth_hash)
    where(provider: auth_hash.provider, uid: auth_hash.uid).first_or_create do |user|
      user.email = auth_hash.info.email
      user.image = auth_hash.info.image
      user.name  = auth_hash.info.name
    end
  end
end
