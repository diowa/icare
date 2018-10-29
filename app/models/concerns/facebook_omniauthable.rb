# frozen_string_literal: true

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

      if block_given?
        yield(@facebook)
      else
        @facebook
      end
    rescue Koala::Facebook::APIError => e
      logger.info e.to_s
      nil # or return a custom object
    end

    def update_facebook_data!
      update_connection! 'friends'
      update_connection! 'permissions'
      update_favorites!
      update_user_fields!
      update_attribute :facebook_data_cached_at, Time.now.utc
    end

    def facebook_permission?(permission)
      facebook_permissions? && facebook_permissions.include?('permission' => permission.to_s, 'status' => 'granted')
    end

    def update_info_from_auth_hash!(auth_hash)
      update(
        email: auth_hash.info.email,
        image: auth_hash.info.image,
        name: auth_hash.info.name,
        access_token: auth_hash.credentials.token,
        access_token_expires_at: Time.zone.at(auth_hash.credentials.expires_at)
      )
    end

    private

    # The person's birthday. This is a fixed format string, like
    # MM/DD/YYYY. However, people can control who can see the year they
    # were born separately from the month and day so this string can be
    # only the year (YYYY) or the month + day (MM/DD)
    #
    # Ref: https://developers.facebook.com/docs/graph-api/reference/user/
    def birthday_from_graph_api(ga_birthday)
      Date.strptime(ga_birthday, '%m/%d/%Y').at_midnight if ga_birthday&.match?(%r{\A[0-9]{2}/[0-9]{2}/[0-9]{4}\z})
    end

    def locale_from_graph_api(ga_locale)
      ga_locale.tr('_', '-') if ga_locale.present? && !locale?
    end

    def update_connection!(connection)
      result = facebook do |fb|
        fb.get_connections('me', connection)
      end
      return unless result

      update_attribute :"facebook_#{connection}", result
    end

    def update_favorites!
      result = facebook do |fb|
        fb.batch do |batch_api|
          %w[music books movies television games].each do |favorite|
            batch_api.get_connections('me', favorite)
          end
        end
      end
      return unless result

      update_attribute :facebook_favorites, result.select { |r| r.is_a?(Array) }.flatten
    end

    def update_user_fields!
      result = facebook do |fb|
        fb.get_object('me?fields=birthday,gender,languages,locale,verified')
      end
      return unless result

      update(
        birthday: birthday_from_graph_api(result['birthday']),
        facebook_verified: result['verified'],
        gender: result['gender'],
        languages: result['languages'] || [],
        locale: locale_from_graph_api(result['locale'])
      )
    end
  end
end
