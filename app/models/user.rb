class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  GENDER = %w(male female)

  paginates_per 25

  attr_accessible :nationality, :time_zone, :locale, :vehicle_avg_consumption

  has_and_belongs_to_many :conversations

  has_many :itineraries, dependent: :destroy
  has_many :feedbacks

  embeds_many :notifications
  embeds_many :references, cascade_callbacks: true

  # Auth / Credentials
  field :provider
  field :uid
  field :oauth_token
  field :oauth_expires_at
  # Cache Permissions
  field :facebook_permissions
  # Info
  field :email
  field :name
  field :facebook_verified, type: Boolean, default: false
  # Extra
  field :username
  field :gender
  field :bio
  field :languages, type: Hash, default: {}

  # More info requiring special permissions
  field :birthday, type: Date
  field :work, type: Hash, default: {}
  field :education, type: Hash, default: {}

  # Icare
  field :nationality
  field :vehicle_avg_consumption, type: Float, default: (1.741*7.0/100.0).round(2)

  # Account
  field :locale
  field :time_zone, default: "UTC" # NOTE think about it
  field :telephone
  field :admin, type: Boolean, default: false
  #field :access_level, type: Integer, default: 0
  field :banned, type: Boolean, default: false

  field :send_email_messages, type: Boolean, default: true
  field :send_email_references, type: Boolean, default: true

  validates :gender, inclusion: GENDER, allow_blank: true
  validates :nationality, inclusion: Country.all.map{ |c| c.code }, allow_blank: true
  validates :time_zone, inclusion: ActiveSupport::TimeZone.zones_map.map{ |zone| zone.first }, allow_blank: true
  validates :vehicle_avg_consumption, numericality: { greater_than: 0, less_than: 10 }, presence: true
  #validates :access_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  scope :sorted, asc(:name)

  def self.from_omniauth(auth)
    if user = where(auth.slice("provider", "uid")).first
      user.update_fields_from_omniauth(auth)
      user.save!
      user
    else
      create_from_omniauth(auth)
    end
  end

  def self.create_from_omniauth(auth)
    create! do |user|

      # Auth / Credentials
      user.provider = auth.provider
      user.uid = auth.uid
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)

      user.update_fields_from_omniauth(auth)
    end
  end

  def update_fields_from_omniauth(auth)
    # Info
    self.email = auth.info.email
    self.name = auth.info.name
    self.facebook_verified = auth.info.verified || false

    # Extra
    self.username = auth.extra.raw_info.username
    self.gender = auth.extra.raw_info.gender
    self.bio = auth.extra.raw_info.bio
    self.languages = auth.extra.raw_info.languages || {}

    # Locale (with priority to icare)
    self.locale = auth.extra.raw_info.locale.gsub(/_/,"-") unless self.locale?

    # Extras (extra permissions required)
    self.birthday = Date.strptime(auth.extra.raw_info.birthday, "%m/%d/%Y").at_midnight
    self.work = auth.extra.raw_info.work || {}
    self.education = auth.extra.raw_info.education || {}

    # Cache permissions
    facebook do |fb|
      self.facebook_permissions = fb.get_connections("me", "permissions")[0]
    end
  end

  def facebook
    @facebook ||= Koala::Facebook::API.new(oauth_token)
    block_given? ? yield(@facebook) : @facebook
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
    nil # or consider a custom null object
    # TODO
    # Koala::Facebook::APIError: OAuthException: Error validating access token: Session does not match current stored session. This may be because the user changed the password since the time the session was created or Facebook has changed the session for security reasons.
  end

  def has_facebook_permission(scope)
    facebook_permissions? ? facebook_permissions[scope.to_s].to_i == 1 : false
  end

  def facebook_connections(connection)
    facebook { |fb| fb.get_connections("me", connection.to_s) }
  end

  def facebook_likes
    # TODO cache!!!!!
    #@facebook_likes ||= facebook_connections(:likes)
    fb_favorites = ["music", "books", "movies", "television", "games", "activities", "interests"] #"athletes", "sports_teams", "sports", "inspirational_people"
    facebook.batch do |batch_api|
      fb_favorites.each do |favorite|
        batch_api.get_connections('me', favorite)
      end
    end.flatten
  end

  def friends_with_privacy(friends = 0)
    case friends
      when 0...10
        "10-"
      when 10...100
        "#{friends/10}0+"
      when 100...1000
        "#{friends/100}00+"
      when 1000...5000
        "#{friends/1000}000+"
      else
        "5000"
    end
  end

  def facebook_profile_batch(other_user = nil)
    fb_favorites = ["music", "books", "movies", "television", "games", "activities", "interests"] #"athletes", "sports_teams", "sports", "inspirational_people"
    batch = facebook.batch do |batch_api|
      batch_api.get_connections('me', "friends", limit: 1001)
      batch_api.get_connections('me', "mutualfriends/#{other_user.uid}") if other_user
      fb_favorites.each do |favorite|
        batch_api.get_connections('me', favorite)
      end
    end
    if other_user
      { friends: friends_with_privacy(batch[0].size), mutualfriends: batch[1], likes: batch[2..-1].flatten }
    else
      { friends: friends_with_privacy(batch[0].size), likes: batch[1..-1].flatten }
    end
  end

  def email_inclusion
    return if Rails.env.development? || Rails.env.test? || email =~ /@cs\.fake$/
    unless BetaInvite.where(email: email).first
      self.errors.add(:email, "Sorry, minstrels is in private beta. You are not authorized to register.")
    end
  end

  def age
    ((Time.now.at_midnight - birthday.at_midnight) / 1.year).floor if birthday?
  end

  def age_sex_nationality
    [age, (User.human_attribute_name("gender_#{gender}").downcase if gender?), nationality_name].compact.join(" / ")
  end

  def nationality_name
    Country.where(code: nationality).first._name if nationality?
  end

  def short_about
    about.truncate(500) if about?
  end

  def first_name
    @first_name ||= name.split[0] if name?
  end

  def to_s
    name || ""
  end

  def to_param
    username || uid || _id
  end

  def profile_picture
    "http://graph.facebook.com/#{uid}/picture?type=square"
  end

  def unread_conversations_count
    conversations.unread(self).size
  end

  def unread_references_count
    references.unread.size
  end

  protected
end
