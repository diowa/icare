module Concerns
  module User
    module Facebook
      extend ActiveSupport::Concern

      included do
        def facebook
          @facebook ||= Koala::Facebook::API.new(oauth_token)
          block_given? ? yield(@facebook) : @facebook
        rescue Koala::Facebook::APIError => e
          logger.info e.to_s
          nil # or consider a custom null object
          # TODO
          # Koala::Facebook::APIError: OAuthException: Error validating access token: Session does not match current stored session. This may be because the user changed the password since the time the session was created or Facebook has changed the session for security reasons.
        end

        def has_facebook_permission?(scope)
          facebook_permissions? ? facebook_permissions[scope.to_s].to_i == 1 : false
        end

        def cache_facebook_data?
          favorites = %w(music books movies television games activities interests) #athletes sports_teams sports inspirational_people
          facebook do |fb|
            result = fb.batch do |batch_api|
              batch_api.get_connections('me', 'friends')
              favorites.each do |favorite|
                batch_api.get_connections('me', favorite)
              end
            end
            if result.any?
              self.facebook_friends = result[0] ? result[0] : []
              self.facebook_favorites = result[1] ? result[1..-1].flatten : []
              return true
            end
          end
          false
        end
      end

      module ClassMethods
      end
    end
  end
end
