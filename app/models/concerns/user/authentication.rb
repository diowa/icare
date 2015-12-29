module Concerns
  module User
    module Authentication
      extend ActiveSupport::Concern

      included do
        def set_fields_from_omniauth(auth)
          # Auth / Credentials (token, expires_at)
          set_credentials auth.credentials

          # Info (email, name, verified)
          set_info auth.info

          # Extra raw info (username, gender, bio, languages)
          set_extra_raw_info auth.extra.raw_info

          # Extra raw info requiring special permissions (birthday, work, education)
          set_extra_raw_info_special_permissions auth.extra.raw_info

          # Locale, with priority to application setting
          self.locale = auth.extra.raw_info.locale.tr('_', '-') if auth.extra.raw_info.locale && !self.locale?

          # Username and uid array
          self.username_or_uid = [username, uid]

          # Permissions
          set_permissions

          # Schedule facebook data cache
          CacheFacebookDataJob.perform_later id.to_s
        end

        def can_access?
          return true unless APP_CONFIG.facebook.restricted_group_id
          facebook do |fb|
            groups = fb.get_connections('me', 'groups')
            group = groups.find { |g| g['id'] == APP_CONFIG.facebook.restricted_group_id }
            self.admin = group.present? && group['administrator']
            group.present?
          end
        end

        private

        def set_credentials(credentials)
          self.oauth_token = credentials.token
          self.oauth_expires_at = Time.zone.at credentials.expires_at
        end

        def set_info(info)
          self.email = info.email
          self.name = info.name
          self.facebook_verified = info.verified || false
        end

        def set_extra_raw_info(raw_info)
          self.username = raw_info.username
          self.gender = raw_info.gender
          self.bio = raw_info.bio
          self.languages = raw_info.languages || []
        end

        def set_extra_raw_info_special_permissions(raw_info)
          self.birthday = Date.strptime(raw_info.birthday, '%m/%d/%Y').at_midnight if raw_info.birthday
          self.work = raw_info.work || []
          self.education = raw_info.education || []
        end

        def set_permissions
          facebook do |fb|
            self.facebook_permissions = fb.get_connections('me', 'permissions')[0]
          end
        end
      end

      module ClassMethods
        def from_omniauth(auth)
          user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
          return nil if user.new_record? && !user.can_access?
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
