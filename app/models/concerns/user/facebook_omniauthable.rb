# frozen_string_literal: true
module Concerns
  module User
    module FacebookOmniauthable
      extend ActiveSupport::Concern

      included do
        field :access_token
        field :access_token_expires_at

        field :facebook_data_cached_at, type: DateTime, default: '2012-09-06'
        field :facebook_favorites,      type: Array,    default: []
        field :facebook_friends,        type: Array,    default: []
        field :facebook_permissions,    type: Hash,     default: {}
        field :facebook_verified,       type: Boolean,  default: false

        def facebook
          @facebook ||= Koala::Facebook::API.new(access_token)
          block_given? ? yield(@facebook) : @facebook
        rescue Koala::Facebook::APIError => e
          logger.info e.to_s
          nil # or consider a custom null object
          # TODO: Investigate this error:
          # Koala::Facebook::APIError: OAuthException: Error validating access token: Session does not match current stored session. This may be because the user changed the password since the time the session was created or Facebook has changed the session for security reasons.
        end

        def facebook_permission?(scope)
          facebook_permissions? && facebook_permissions[scope.to_s].to_i == 1
        end

        def cache_facebook_data!
          facebook do |fb|
            result = fb.batch do |batch_api|
              batch_api.get_connections('me', 'friends')

              %w(music books movies television games).each do |favorite|
                batch_api.get_connections('me', favorite)
              end
            end
            if result.any?
              self.facebook_friends   = result[0].to_a
              self.facebook_favorites = result[1..-1].select { |r| r.class == Koala::Facebook::API::GraphCollection }.flatten
            end
            self.facebook_data_cached_at = Time.now.utc
            return save
          end
          false
        end

        def update_auth_hash_info!(auth_hash)
          update_attributes(
            email:                   auth_hash.info.email,
            name:                    auth_hash.info.name,
            image:                   auth_hash.info.image,
            access_token:            auth_hash.credentials.token,
            access_token_expires_at: Time.zone.at(auth_hash.credentials.expires_at)
          )
        end

        # def update_facebook_info(auth_hash)
        #   # Extra raw info (username, gender, bio, languages)
        #   # set_extra_raw_info auth.extra.raw_info
        #
        #   # Extra raw info requiring special permissions (birthday, work, education)
        #   # set_extra_raw_info_special_permissions auth.extra.raw_info
        #
        #   # Locale, with priority to application setting
        #   # self.locale = auth.extra.raw_info.locale.tr('_', '-') if auth.extra.raw_info.locale && !locale?
        #
        #   # Permissions
        #   update_permissions
        # end

        private

        def update_permissions
          facebook do |fb|
            self.facebook_permissions = fb.get_connections('me', 'permissions')[0]
          end
        end

        # def set_extra_raw_info(raw_info)
        #   self.username  = raw_info.username
        #   self.gender    = raw_info.gender
        #   self.bio       = raw_info.bio
        #   self.languages = raw_info.languages || []
        # end

        # def set_extra_raw_info_special_permissions(raw_info)
        #   self.birthday  = Date.strptime(raw_info.birthday, '%m/%d/%Y').at_midnight if raw_info.birthday
        #   self.work      = raw_info.work || []
        #   self.education = raw_info.education || []
        # end
      end
    end
  end
end
