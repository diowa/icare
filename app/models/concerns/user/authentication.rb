module Concerns
  module User
    module Authentication
      extend ActiveSupport::Concern

      included do
        def update_fields_from_omniauth(auth)
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
          self.birthday = Date.strptime(auth.extra.raw_info.birthday, "%m/%d/%Y").at_midnight
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
      end

      module ClassMethods
        # TODO waiting for mongoid 3.1.0
        # where(auth.slice(:provider, :uid)).first_or_initialize.tap

        def from_omniauth(auth)
          user = where(auth.slice(:provider, :uid)).first || ::User.new
          user.provider = auth.provider
          user.uid = auth.uid
          user.update_fields_from_omniauth auth
          user.save!
          user
        end
      end
    end
  end
end
