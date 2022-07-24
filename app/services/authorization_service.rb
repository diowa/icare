# frozen_string_literal: true

module AuthorizationService
  extend self

  delegate :delete_user, to: :auth0_client

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
