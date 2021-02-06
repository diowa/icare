# frozen_string_literal: true

module AuthorizationService
  class << self
    private

    def auth0_client
      @auth0_client ||= Auth0Client.new(
        client_id:     APP_CONFIG.auth0.client_id,
        client_secret: APP_CONFIG.auth0.client_secret,
        domain:        APP_CONFIG.auth0.domain,
        api_version:   2
      )
    end
  end

  module_function

  def delete_user(user_uid)
    auth0_client.delete_user user_uid
  end
end
