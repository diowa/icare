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
        field :facebook_permissions,    type: Array,    default: []
        field :facebook_verified,       type: Boolean,  default: false

        def facebook
          # TODO: Request a Long-Term token
          @facebook ||= Koala::Facebook::API.new(access_token)
          block_given? ? yield(@facebook) : @facebook
        rescue Koala::Facebook::APIError => e
          logger.info e.to_s
          nil # or return a custom object
        end

        def facebook_permission?(permission)
          facebook_permissions? && facebook_permissions.include?('permission' => permission.to_s, 'status' => 'granted')
        end

        def cache_facebook_data!
          result = facebook do |fb|
            fb.batch do |batch_api|
              batch_api.get_connections('me', 'friends')

              %w(music books movies television games).each do |favorite|
                batch_api.get_connections('me', favorite)
              end
            end
          end

          if result && result.any?
            self.facebook_friends   = result[0].to_a
            self.facebook_favorites = result[1..-1].select { |r| r.class == Koala::Facebook::API::GraphCollection }.flatten
            self.facebook_data_cached_at = Time.now.utc
            save
          else
            false
          end
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
        # end

        private

        def update_permissions!
          permissions = facebook do |fb|
            fb.get_connections('me', 'permissions')
          end

          update_attribute :facebook_permissions, permissions || []
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
