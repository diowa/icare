module Concerns
  module User
    module Authentication
      extend ActiveSupport::Concern

      included do
        def set_fields_from_omniauth(auth)
          # Auth / Credentials
          self.oauth_token = auth.credentials.token
          self.oauth_expires_at = Time.at auth.credentials.expires_at

          # Info
          self.email = auth.info.email
          self.name = auth.info.name
          self.facebook_verified = auth.info.verified || false

          # Extra
          self.username = auth.extra.raw_info.username
          self.gender = auth.extra.raw_info.gender
          self.bio = auth.extra.raw_info.bio
          self.languages = auth.extra.raw_info.languages || {}

          # Locale (gives priority to application setting)
          self.locale = auth.extra.raw_info.locale.gsub(/_/,'-') unless self.locale?

          # Extras (extra permissions are required)
          self.birthday = Date.strptime(auth.extra.raw_info.birthday, "%m/%d/%Y").at_midnight if auth.extra.raw_info.birthday
          self.work = auth.extra.raw_info.work || {}
          self.education = auth.extra.raw_info.education || {}

          # Username and uid array
          self.username_or_uid = [ username, uid ]

          # Cache permissions
          facebook do |fb|
            self.facebook_permissions = fb.get_connections('me', 'permissions')[0]
          end

          # Schedule facebook data cache
          Resque.enqueue(FacebookDataCacher, id)
        rescue Redis::CannotConnectError
        end

        def has_access?
          return true unless APP_CONFIG.facebook.restricted_group_id
          facebook do |fb|
            groups = fb.get_connections('me', 'groups')
            group = groups.select{ |g| g['id'] == APP_CONFIG.facebook.restricted_group_id }.first
            self.admin = group.present? && group['administrator']
            group.present?
          end
        end
      end

      module ClassMethods
        def from_omniauth(auth)
          user = where(auth.slice(:provider, :uid)).first_or_initialize
          return nil if user.new_record? && !user.has_access?
          user.provider = auth.provider
          user.uid = auth.uid
          user.set_fields_from_omniauth auth
          user.save!
          user
        end
      end
    end
  end
end
