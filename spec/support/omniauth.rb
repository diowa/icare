# frozen_string_literal: true

OMNIAUTH_MOCKED_AUTHHASH = OmniAuth::AuthHash.new('provider'    => 'auth0',
                                                  'uid'         => '123456',
                                                  'info'        => {
                                                    'email' => 'test@example.com',
                                                    'name'  => 'John Doe',
                                                    'image' => 'https://s.gravatar.com/avatar/123456?s=480&r=pg&d=https%3A%2F%2Fcdn.auth0.com%2Favatars%2Fta.png'
                                                  },
                                                  'credentials' => {
                                                    'token'      => 'token',
                                                    'expires_at' => 2.days.from_now.to_i,
                                                    'expires'    => true
                                                  },
                                                  'extra'       => {
                                                    'raw_info' => {
                                                      'name'  => 'test@example.com',
                                                      'email' => 'John Doe',
                                                      'id'    => '123456'
                                                    }
                                                  })

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:auth0] = OMNIAUTH_MOCKED_AUTHHASH

module OmniauthMacros
  def login_via_auth0
    visit root_path
    first("form[action=\"#{user_auth0_omniauth_authorize_path}\"] button").click
  end
end

RSpec.configure do |config|
  config.include OmniauthMacros
end
